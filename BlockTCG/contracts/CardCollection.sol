// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title CardCollection
/// @notice ERC1155 collectible cards with 3 rarity tiers and blind-box pack opening
contract CardCollection is ERC1155, Ownable {

    IERC20 public immutable paymentToken;

    uint256 public constant PACK_PRICE = 10 * 10 ** 18; // 10 CARD tokens per pack

    /// @notice Rarity tiers for cards
    enum Rarity { Common, Rare, SuperRare }

    /// @notice On-chain metadata for each card type
    struct CardInfo {
        string name;
        Rarity rarity;
        uint256 maxSupply;
        uint256 currentSupply;
    }

    mapping(uint256 => CardInfo) public cards;  // tokenId => CardInfo
    uint256 public totalCardTypes;

    // Rarity buckets used for weighted random selection
    uint256[] public commonIds;
    uint256[] public rareIds;
    uint256[] public superRareIds;

    // Nonce for pseudo-randomness (sufficient for demo; use Chainlink VRF in production)
    uint256 private _nonce;

    // ─── Events ───────────────────────────────────────────────────────
    event PackOpened(address indexed user, uint256 tokenId, string cardName, Rarity rarity);
    event CardRegistered(uint256 tokenId, string name, Rarity rarity, uint256 maxSupply);

    /// @param _paymentToken Address of the deployed CollectibleToken (ERC20)
    /// @param _uri Metadata URI e.g. "ipfs://YOUR_CID/{id}.json"
    constructor(address _paymentToken, string memory _uri)
        ERC1155(_uri)
        Ownable(msg.sender)
    {
        paymentToken = IERC20(_paymentToken);
    }

    /// @notice Register a new card type. Owner only. Call once per card during setup.
    /// @param tokenId Unique ID for this card (1-20 Common, 21-35 Rare, 36-45 SuperRare)
    /// @param name Display name of the card
    /// @param rarity 0=Common, 1=Rare, 2=SuperRare
    /// @param maxSupply Maximum copies that can ever be minted
    function registerCard(
        uint256 tokenId,
        string calldata name,
        Rarity rarity,
        uint256 maxSupply
    ) external onlyOwner {
        require(cards[tokenId].maxSupply == 0, "Card already registered");
        require(maxSupply > 0, "Max supply must be > 0");

        cards[tokenId] = CardInfo(name, rarity, maxSupply, 0);
        totalCardTypes++;

        // Add tokenId to the correct rarity bucket
        if (rarity == Rarity.Common)        commonIds.push(tokenId);
        else if (rarity == Rarity.Rare)     rareIds.push(tokenId);
        else                                superRareIds.push(tokenId);

        emit CardRegistered(tokenId, name, rarity, maxSupply);
    }

    /// @notice Open a pack: spend CARD tokens, receive 1 random card
    /// @dev Weighted odds: 70% Common, 25% Rare, 5% Super Rare
    function openPack() external {
        // Step 1: Collect payment
        require(
            paymentToken.transferFrom(msg.sender, address(this), PACK_PRICE),
            "Payment failed: approve CARD tokens first"
        );

        // Step 2: Pick rarity tier
        uint256 rand = _random(100);
        uint256 tokenId;

        if (rand < 70) {
            tokenId = _pickFromBucket(commonIds);       // 70% Common
        } else if (rand < 95) {
            tokenId = _pickFromBucket(rareIds);         // 25% Rare
        } else {
            tokenId = _pickFromBucket(superRareIds);    // 5% Super Rare
        }

        // Step 3: Enforce max supply and mint
        CardInfo storage card = cards[tokenId];
        require(card.currentSupply < card.maxSupply, "Card sold out, retry");
        card.currentSupply++;
        _mint(msg.sender, tokenId, 1, "");

        emit PackOpened(msg.sender, tokenId, card.name, card.rarity);
    }

    /// @notice Owner withdraws CARD tokens collected from pack sales
    function withdrawTokens(address to) external onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0, "Nothing to withdraw");
        paymentToken.transfer(to, balance);
    }

    /// @notice Returns full card info for a given tokenId
    function getCardInfo(uint256 tokenId) external view returns (CardInfo memory) {
        return cards[tokenId];
    }

    /// @notice Returns all tokenIds in a rarity bucket
    function getCommonIds() external view returns (uint256[] memory) { return commonIds; }
    function getRareIds() external view returns (uint256[] memory) { return rareIds; }
    function getSuperRareIds() external view returns (uint256[] memory) { return superRareIds; }

    // ─── Internal helpers ─────────────────────────────────────────────

    /// @dev Picks a random available tokenId from a rarity bucket, skips sold-out cards
    function _pickFromBucket(uint256[] storage bucket) internal returns (uint256) {
        require(bucket.length > 0, "No cards in this rarity tier");
        uint256 startIdx = _random(bucket.length);
        for (uint256 i = 0; i < bucket.length; i++) {
            uint256 idx = (startIdx + i) % bucket.length;
            uint256 id = bucket[idx];
            if (cards[id].currentSupply < cards[id].maxSupply) {
                return id;
            }
        }
        revert("All cards in this rarity tier are sold out");
    }

    /// @dev Pseudo-random using block data + nonce. Not secure against miners — use Chainlink VRF in production.
    function _random(uint256 modulus) internal returns (uint256) {
        _nonce++;
        return uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            msg.sender,
            _nonce
        ))) % modulus;
    }
}