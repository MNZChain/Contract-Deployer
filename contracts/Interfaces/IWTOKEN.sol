// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IWTOKEN {
    function deposit() external payable;

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);
}
