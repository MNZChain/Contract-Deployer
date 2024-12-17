// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../Mainnetz/Dex/ZodiacHelper.sol";

//=====================\\
//+-+-+-+-+-+-+-+-+-+-+\\
//|c|h|e|f|.|c|o|d|e|s|\\
//+-+-+-+-+-+-+-+-+-+-+\\
//=====================\\

/**
 * @title  Standardised ERC20 token with burnable and Zodiac Swap v2 router integration and launch/burn abilities.
 * @author chef@mainnetz.io
 **/

contract NETZToken is ERC20, ERC20Burnable, Ownable, ZodiacHelper {
    address public tradingPair;
    bool public launched;

    modifier WhenLaunched() {
        require(launched, "Token not launched yet");
        _;
    }

    modifier WhenNotLaunched() {
        require(!launched, "Token is all ready launched");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        address _owner
    ) ERC20(_name, _symbol) Ownable(msg.sender) {
        _mint(_owner, _supply);
        tradingPair = createPair(address(this));
        _transferOwnership(_owner);
    }

    function manualLaunch() external WhenNotLaunched onlyOwner {
        launched = true;
    }

    function addLiquidityAndLaunch(
        uint256 _tokenAmount
    ) external payable WhenNotLaunched returns (bool) {
        _approve(msg.sender, address(this), _tokenAmount);
        _transfer(msg.sender, address(this), _tokenAmount);
        _approve(address(this), address(router), _tokenAmount);
        router.addLiquidityETH{value: msg.value}(
            address(this),
            _tokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
        launched = true;
        return launched;
    }

    function burnLP(address lpAddress) public WhenLaunched {
        INETZPair lp = INETZPair(lpAddress);
        uint256 balance = lp.balanceOf(address(msg.sender));
        require(
            lp.allowance(msg.sender, address(this)) >= balance,
            "Approve LP first"
        );
        lp.transferFrom(
            msg.sender,
            address(0x000000000000000000000000000000000000dEaD),
            lp.balanceOf(address(msg.sender))
        );
    }

    function swapCoinForToken(
        uint256 minAmount
    ) public payable WhenLaunched returns (bool) {
        require(msg.value > 0, "No Ether sent");
        router.swapExactETHForTokens{value: msg.value}(
            minAmount,
            getPath(),
            msg.sender,
            block.timestamp
        );
        return true;
    }

    function swapTokenForCoin(
        uint256 amount,
        uint256 minAmount
    ) public WhenLaunched returns (bool) {
        require(amount > 0, "No Tokens to swap");
        require(amount <= balanceOf(msg.sender), "Insufficient balance");

        _approve(msg.sender, address(this), amount);
        transferFrom(msg.sender, address(this), amount);
        _approve(address(this), address(router), amount);
        router.swapExactTokensForETH(
            amount,
            minAmount,
            getPath(),
            msg.sender,
            block.timestamp
        );
        return true;
    }

    function swapTokensForTokens(
        uint256 amount,
        uint256 minAmount,
        address[] memory path
    ) public WhenLaunched returns (bool) {
        require(amount > 0, "No Tokens to swap");
        require(amount <= balanceOf(msg.sender), "Insufficient balance");
        _approve(msg.sender, address(this), amount);
        transferFrom(msg.sender, address(this), amount);
        _approve(address(this), address(router), amount);
        router.swapExactTokensForTokens(
            amount,
            minAmount,
            path,
            msg.sender,
            block.timestamp
        );
        return true;
    }

    function getPath() public view returns (address[] memory path) {
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(this);
    }
}
