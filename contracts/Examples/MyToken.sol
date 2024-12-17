// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../Mainnetz/Core/FeeReceiver.sol";

contract MyToken is FeeReceiver, ERC20, ERC20Burnable {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _supply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _supply);
        // FeeReceiver constructor is called automatically,
        // registering the deployer as the fee recipient
    }

    // Implement your token functionality here...
}
