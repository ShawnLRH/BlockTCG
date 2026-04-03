// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title CollectibleToken
/// @notice Platform currency (CARD) used to buy packs and trade on the marketplace
contract CollectibleToken is ERC20, Ownable {

    uint256 public constant FAUCET_AMOUNT = 100 * 10 ** 18;
    uint256 public constant FAUCET_COOLDOWN = 1 days;

    mapping(address => uint256) public lastFaucetClaim;

    /// @param initialSupply Total tokens minted to deployer on launch
    constructor(uint256 initialSupply) ERC20("CollectibleToken", "CARD") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /// @notice Claim 100 CARD tokens once per day (for demo/testnet use)
    function faucet() external {
        require(
            block.timestamp >= lastFaucetClaim[msg.sender] + FAUCET_COOLDOWN,
            "Faucet: cooldown not expired"
        );
        lastFaucetClaim[msg.sender] = block.timestamp;
        _mint(msg.sender, FAUCET_AMOUNT);
    }

    /// @notice Owner can mint tokens to any address (e.g., rewards)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}