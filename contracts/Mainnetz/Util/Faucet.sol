// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../Core/FeeReceiver.sol";

contract Faucet is FeeReceiver {
    uint256 public claimAmount = 0.05 ether;

    mapping(address => bool) public hasClaimed;

    event Claim(address indexed to);
    event Donation(uint256 value);

    function claim(address _user) public {
        require(
            address(this).balance > claimAmount,
            "No Netz available in the faucet"
        );
        require(!hasClaimed[_user], "User has already claimed");
        hasClaimed[_user] = true;
        (bool success, ) = payable(_user).call{value: claimAmount}("");
        require(success, "Transfer failed");
        emit Claim(_user);
    }

    function donate() public payable {
        emit Donation(msg.value);
    }

    receive() external payable {
        emit Donation(msg.value);
    }
}
