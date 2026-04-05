// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {VRFConsumerBaseV2Plus} from "https://cdn.jsdelivr.net/npm/@chainlink/contracts@1.3.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "https://cdn.jsdelivr.net/npm/@chainlink/contracts@1.3.0/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

interface ICollection1155VRF {
    function mintCard(address to, uint256 cardId, uint256 amount) external;
    function exists(uint256 cardId) external view returns (bool);
    function remainingSupply(uint256 cardId) external view returns (uint256);
}

contract DropManagerVRF is VRFConsumerBaseV2Plus, ReentrancyGuard, Pausable {
    struct RequestStatus {
        address buyer;
        uint32 quantity;
        uint256 totalCost;
        bool exists;
        bool fulfilled;
    }

    uint32 public constant CARDS_PER_PACK = 5;

    ICollection1155VRF public immutable collection;
    IERC20 public immutable paymentToken;

    address public treasury;
    uint256 public packPrice;

    uint256 public totalPacksSold;
    uint256 public totalPacksOpened;
    uint256 public pendingReservedPacks;

    uint256 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit;
    uint16 public requestConfirmations;
    bool public enableNativePayment;

    uint256[] private remainingPool;
    uint256[] private _allRequestIds;

    mapping(uint256 => RequestStatus) private _requests;
    mapping(uint256 => uint256[]) private _requestRandomWords;
    mapping(uint256 => uint256[]) private _requestCardIds;

    error InvalidAddress();
    error InvalidAmount();
    error CardDoesNotExist(uint256 cardId);
    error CardSupplyUnavailable(uint256 cardId);
    error NotEnoughAvailablePacks();
    error RequestNotFound(uint256 requestId);
    error ERC20TransferFailed();

    event PoolSeeded(uint256 indexed cardId, uint256 copiesAdded);
    event PackPurchaseRequested(
        uint256 indexed requestId,
        address indexed buyer,
        uint32 quantity,
        uint256 totalCost
    );
    event PackFulfilled(
        uint256 indexed requestId,
        address indexed buyer
    );
    event PackPriceUpdated(uint256 newPrice);
    event TreasuryUpdated(address newTreasury);
    event SubscriptionIdUpdated(uint256 newSubscriptionId);
    event VRFConfigUpdated(
        bytes32 newKeyHash,
        uint32 newCallbackGasLimit,
        uint16 newRequestConfirmations,
        bool newEnableNativePayment
    );
    event PaymentsWithdrawn(address indexed treasury, uint256 amount);

    constructor(
        address collectionAddress,
        address paymentTokenAddress,
        address vrfCoordinator,
        uint256 vrfSubscriptionId,
        bytes32 vrfKeyHash,
        uint32 vrfCallbackGasLimit,
        uint16 vrfRequestConfirmations,
        bool vrfEnableNativePayment,
        address treasuryAddress,
        uint256 initialPackPrice
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        if (
            collectionAddress == address(0) ||
            paymentTokenAddress == address(0) ||
            vrfCoordinator == address(0) ||
            treasuryAddress == address(0)
        ) {
            revert InvalidAddress();
        }
        if (initialPackPrice == 0) revert InvalidAmount();

        collection = ICollection1155VRF(collectionAddress);
        paymentToken = IERC20(paymentTokenAddress);

        subscriptionId = vrfSubscriptionId;
        keyHash = vrfKeyHash;
        callbackGasLimit = vrfCallbackGasLimit;
        requestConfirmations = vrfRequestConfirmations;
        enableNativePayment = vrfEnableNativePayment;

        treasury = treasuryAddress;
        packPrice = initialPackPrice;
    }

    /// @notice adds copies of a single card into the pool so they can show up in packs
    function seedPool(uint256 cardId, uint256 copies) external onlyOwner {
        if (!collection.exists(cardId)) revert CardDoesNotExist(cardId);
        if (copies == 0) revert InvalidAmount();
        if (collection.remainingSupply(cardId) < copies) {
            revert CardSupplyUnavailable(cardId);
        }

        for (uint256 i = 0; i < copies; i++) {
            remainingPool.push(cardId);
        }

        emit PoolSeeded(cardId, copies);
    }

    /// @notice same as seedPool but for multiple cards at once
    function seedPoolBatch(
        uint256[] calldata cardIds,
        uint256[] calldata copies
    ) external onlyOwner {
        if (cardIds.length == 0 || cardIds.length != copies.length) {
            revert InvalidAmount();
        }

        for (uint256 i = 0; i < cardIds.length; i++) {
            uint256 cardId = cardIds[i];
            uint256 copyCount = copies[i];

            if (!collection.exists(cardId)) revert CardDoesNotExist(cardId);
            if (copyCount == 0) revert InvalidAmount();
            if (collection.remainingSupply(cardId) < copyCount) {
                revert CardSupplyUnavailable(cardId);
            }

            for (uint256 j = 0; j < copyCount; j++) {
                remainingPool.push(cardId);
            }

            emit PoolSeeded(cardId, copyCount);
        }
    }

    /// @notice updates how much a pack cost
    function setPackPrice(uint256 newPrice) external onlyOwner {
        if (newPrice == 0) revert InvalidAmount();
        packPrice = newPrice;
        emit PackPriceUpdated(newPrice);
    }

    /// @notice changes where the payment tokens get sent when withdrawn
    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert InvalidAddress();
        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    /// @notice updates the chainlink VRF subscription ID
    function setSubscriptionId(uint256 newSubscriptionId) external onlyOwner {
        subscriptionId = newSubscriptionId;
        emit SubscriptionIdUpdated(newSubscriptionId);
    }

    /// @notice allows user to change VRF configs
    function setVRFConfig(
        bytes32 newKeyHash,
        uint32 newCallbackGasLimit,
        uint16 newRequestConfirmations,
        bool newEnableNativePayment
    ) external onlyOwner {
        keyHash = newKeyHash;
        callbackGasLimit = newCallbackGasLimit;
        requestConfirmations = newRequestConfirmations;
        enableNativePayment = newEnableNativePayment;

        emit VRFConfigUpdated(
            newKeyHash,
            newCallbackGasLimit,
            newRequestConfirmations,
            newEnableNativePayment
        );
    }

    /// @notice stops all pack purchases
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice re-enables pack purchases after pausing
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice sends collected payment tokens to the treasury wallet
    function withdrawPayments(uint256 amount) external onlyOwner {
        if (amount == 0) revert InvalidAmount();
        bool ok = paymentToken.transfer(treasury, amount);
        if (!ok) revert ERC20TransferFailed();
        emit PaymentsWithdrawn(treasury, amount);
    }

    /// @notice User pays tokens and function asks chainlink for random numbers
    /// @return requestId the VRF request ID so it can be tracked later
    function buyPack(uint32 quantity)
        external
        whenNotPaused
        nonReentrant
        returns (uint256 requestId)
    {
        if (quantity == 0) revert InvalidAmount();
        if (availablePackCount() < quantity) revert NotEnoughAvailablePacks();

        uint256 totalCost = packPrice * uint256(quantity);

        bool ok = paymentToken.transferFrom(msg.sender, address(this), totalCost);
        if (!ok) revert ERC20TransferFailed();

        uint32 totalCards = quantity * CARDS_PER_PACK;

        pendingReservedPacks += quantity;
        totalPacksSold += quantity;

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: totalCards,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: enableNativePayment})
                )
            })
        );

        _requests[requestId] = RequestStatus({
            buyer: msg.sender,
            quantity: quantity,
            totalCost: totalCost,
            exists: true,
            fulfilled: false
        });

        _allRequestIds.push(requestId);

        emit PackPurchaseRequested(requestId, msg.sender, quantity, totalCost);
    }

    /// @notice chainlink calls this once the random numbers are ready, it then picks cards and mints them
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        RequestStatus storage req = _requests[requestId];
        if (!req.exists) revert RequestNotFound(requestId);

        req.fulfilled = true;

        delete _requestRandomWords[requestId];
        delete _requestCardIds[requestId];

        for (uint256 i = 0; i < randomWords.length; i++) {
            _requestRandomWords[requestId].push(randomWords[i]);

            uint256 poolIndex = randomWords[i] % remainingPool.length;
            uint256 cardId = remainingPool[poolIndex];

            uint256 lastIndex = remainingPool.length - 1;
            if (poolIndex != lastIndex) {
                remainingPool[poolIndex] = remainingPool[lastIndex];
            }
            remainingPool.pop();

            _requestCardIds[requestId].push(cardId);

            collection.mintCard(req.buyer, cardId, 1);
        }

        uint32 packsInRequest = req.quantity;
        totalPacksOpened += packsInRequest;
        pendingReservedPacks -= packsInRequest;

        emit PackFulfilled(requestId, req.buyer);
    }

    /// @notice how many card slots are left in the pool total
    /// @return the size of the remaining pool
    function remainingPoolSize() external view returns (uint256) {
        return remainingPool.length;
    }

    /// @notice how many packs can still be bought
    /// @return number of packs available right now
    function availablePackCount() public view returns (uint256) {
        uint256 reservedSlots = pendingReservedPacks * CARDS_PER_PACK;
        if (remainingPool.length <= reservedSlots) return 0;
        return (remainingPool.length - reservedSlots) / CARDS_PER_PACK;
    }

    /// @notice gives you every VRF request ID that's been created so far
    function allRequestIds() external view returns (uint256[] memory) {
        return _allRequestIds;
    }

    /// @notice look up the basic info for a pack purchase (who bought it, how much)
    function getRequestStatusBasic(uint256 requestId)
        external
        view
        returns (
            address buyer,
            uint32 quantity,
            uint256 totalCost,
            bool exists_,
            bool fulfilled
        )
    {
        RequestStatus storage req = _requests[requestId];
        return (
            req.buyer,
            req.quantity,
            req.totalCost,
            req.exists,
            req.fulfilled
        );
    }

    /// @notice returns the raw random numbers chainlink gave for a request
    function getRequestRandomWords(uint256 requestId)
        external
        view
        returns (uint256[] memory)
    {
        return _requestRandomWords[requestId];
    }

    /// @notice returns which card IDs the user actually got from opening their pack
    function getRequestCardIds(uint256 requestId)
        external
        view
        returns (uint256[] memory)
    {
        return _requestCardIds[requestId];
    }
}
