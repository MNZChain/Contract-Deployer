// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface FeeReward {
    function setContractCreator(
        address contractAddress
    ) external returns (bool);
}

abstract contract FeeReceiver {
    // MainnetZ Fee Setter Contract
    FeeReward public constant feeSetterContract =
        FeeReward(0x000000000000000000000000000000000000f000);

    constructor() {
        feeSetterContract.setContractCreator(address(this));
    }
}
