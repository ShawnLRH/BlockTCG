// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title CardCollection
/// @notice ERC1155 collectible cards storing metadata, rarity, and supply.
///         Blind-box logic and randomness are handled by an external DropManager.
contract CardCollection is ERC1155, Ownable {
    using Strings for uint256;

    /// @notice Rarity tiers for cards
    enum Rarity { Common, Rare, SuperRare }

    /// @notice On-chain metadata for each card type
    struct CardInfo {
        string name;
        Rarity rarity;
        uint256 maxSupply;
        uint256 currentSupply;
    }

    mapping(uint256 => CardInfo) public cards; // tokenId => CardInfo
    uint256 public totalCardTypes;

    // Optional rarity buckets for UI / analytics / future use
    uint256[] public commonIds;
    uint256[] public rareIds;
    uint256[] public superRareIds;

    /// @notice Authorized DropManager contract that can mint cards
    address public dropManager;

    /// @notice Base URI for metadata (e.g. "ipfs://YOUR_CID/")
    string private _baseURI;

    event CardRegistered(uint256 tokenId, string name, Rarity rarity, uint256 maxSupply);
    event DropManagerUpdated(address indexed newDropManager);
    event CardMinted(address indexed to, uint256 indexed tokenId, uint256 amount);

    modifier onlyDropManager() {
        require(msg.sender == dropManager, "Not authorized drop manager");
        _;
    }

    /// @param _uri Base metadata URI, e.g. "ipfs://YOUR_CID/"
    constructor(string memory _uri)
        ERC1155("")
        Ownable(msg.sender)
    {
        _baseURI = _uri;
    }

    /// @notice Returns metadata URI for a token, e.g. "ipfs://CID/1.json"
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(cards[tokenId].maxSupply > 0, "Card not registered");
        return string.concat(_baseURI, tokenId.toString(), ".json");
    }

    /// @notice Set the authorized drop manager
    function setDropManager(address _dropManager) external onlyOwner {
        require(_dropManager != address(0), "Invalid drop manager");
        dropManager = _dropManager;
        emit DropManagerUpdated(_dropManager);
    }

    /// @notice Register a new card type. Owner only.
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

        if (rarity == Rarity.Common) commonIds.push(tokenId);
        else if (rarity == Rarity.Rare) rareIds.push(tokenId);
        else superRareIds.push(tokenId);

        emit CardRegistered(tokenId, name, rarity, maxSupply);
    }

    /// @notice Mint a registered card to a user. Only callable by DropManager.
    function mintCard(address to, uint256 tokenId, uint256 amount) external onlyDropManager {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be > 0");

        CardInfo storage card = cards[tokenId];
        require(card.maxSupply > 0, "Card not registered");
        require(card.currentSupply + amount <= card.maxSupply, "Exceeds max supply");

        card.currentSupply += amount;
        _mint(to, tokenId, amount, "");

        emit CardMinted(to, tokenId, amount);
    }

    /// @notice Returns whether a card exists
    function exists(uint256 tokenId) external view returns (bool) {
        return cards[tokenId].maxSupply > 0;
    }

    /// @notice Returns remaining mintable supply for a card
    function remainingSupply(uint256 tokenId) external view returns (uint256) {
        CardInfo storage card = cards[tokenId];
        if (card.maxSupply == 0) return 0;
        return card.maxSupply - card.currentSupply;
    }

    /// @notice Returns full card info for a given tokenId
    function getCardInfo(uint256 tokenId) external view returns (CardInfo memory) {
        return cards[tokenId];
    }

    function batchRegisterCards(
        uint256[] calldata tokenIds,
        string[] calldata names,
        Rarity[] calldata rarities,
        uint256[] calldata maxSupplies
    ) external onlyOwner {
        require(
            tokenIds.length == names.length &&
            names.length == rarities.length &&
            rarities.length == maxSupplies.length,
            "Array length mismatch"
        );
        require(tokenIds.length > 0, "No cards provided");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            string calldata name = names[i];
            Rarity rarity = rarities[i];
            uint256 maxSupply = maxSupplies[i];

            require(cards[tokenId].maxSupply == 0, "Card already registered");
            require(maxSupply > 0, "Max supply must be > 0");

            cards[tokenId] = CardInfo(name, rarity, maxSupply, 0);
            totalCardTypes++;

            if (rarity == Rarity.Common) {
                commonIds.push(tokenId);
            } else if (rarity == Rarity.Rare) {
                rareIds.push(tokenId);
            } else {
                superRareIds.push(tokenId);
            }

            emit CardRegistered(tokenId, name, rarity, maxSupply);
        }
    }

    /// @notice Returns all tokenIds in each rarity bucket
    function getCommonIds() external view returns (uint256[] memory) { return commonIds; }
    function getRareIds() external view returns (uint256[] memory) { return rareIds; }
    function getSuperRareIds() external view returns (uint256[] memory) { return superRareIds; }
}
