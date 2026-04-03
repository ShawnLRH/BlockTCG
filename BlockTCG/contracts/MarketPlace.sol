// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract CardMarketplace is ERC1155Holder {

    IERC1155 public cardContract;
    IERC20 public tokenContract;

    address public owner;
    uint256 public listingCount;
    uint256 public commissionFee; 

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;

    /// @notice Initialize marketplace with token contracts and commission fee
    constructor(address _cardContract, address _tokenContract, uint256 _fee) {
        cardContract = IERC1155(_cardContract);
        tokenContract = IERC20(_tokenContract);
        owner = msg.sender;
        commissionFee = _fee;
    }

    /// @notice List ERC1155 cards for sale on the marketplace
    function list(uint256 tokenId, uint256 amount, uint256 price) public {
        require(price > 0, "Listing price must be greater than 0");

        cardContract.safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        listings[listingCount] = Listing(msg.sender, tokenId, amount, price);
        listingCount++;
    }

    /// @notice Remove a listing and return cards to seller
    function unlist(uint256 listingId) public {
        Listing memory item = listings[listingId];
        require(msg.sender == item.seller, "Not seller");

        cardContract.safeTransferFrom(address(this), item.seller, item.tokenId, item.amount, "");

        delete listings[listingId];
    }

    /// @notice Buy a listed card using ERC20 tokens
    function buy(uint256 listingId) public {
        Listing memory item = listings[listingId];

        require(item.price > 0, "Not listed");

        tokenContract.transferFrom(msg.sender, item.seller, item.price);

        if (commissionFee > 0) {
            tokenContract.transferFrom(msg.sender, owner, commissionFee);
        }

        cardContract.safeTransferFrom(address(this), msg.sender, item.tokenId, item.amount, "");

        delete listings[listingId];
    }

    /// @notice Get details of a listing
    /// @return Listing struct containing seller, tokenId, amount, and price
    function getListing(uint256 listingId) public view returns (Listing memory) {
        return listings[listingId];
    }
}