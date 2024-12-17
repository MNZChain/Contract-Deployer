// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@vialabs-io/npm-contracts/MessageClient.sol";
import "../../Interfaces/IWTOKEN.sol";

/**
 * @title Bridged WNETZ
 * @dev A cross-chain compatible WNETZ contract that enables cross chain implementation of NETZ.
 * @author https://www.mainnetz.io
 */
contract BridgedWNETZ is ERC20, ERC20Permit, MessageClient {
    // Fee numerator for calculating the transaction fee (e.g., 30 = 0.3% fee).
    uint256 public FEE_NUMERATOR = 100;

    // Fee denominator for calculating the transaction fee (e.g., 10000 = basis point calculation).
    uint256 public constant FEE_DENOMINATOR = 10000;

    // Bridge enable/disable status. If false, bridging is not allowed.
    bool public BRIDGE_ENABLED = false;

    // Additional gas fee variable. If set, bridging incurs an additional native charge.
    uint256 public GAS_FEE = 0;

    // Reference to Base Wrapped ETH token contract.
    IWTOKEN public WETH = IWTOKEN(0x4200000000000000000000000000000000000006);

    // Event emitted when tokens are bridged out of the source chain.
    event Incoming(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    // Event emitted when tokens are bridged into the current chain.
    event Outgoing(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );

    // Event emitted when the bridge fee is updated.
    event FeeChanged(uint256 newFee);

    // Event emitted when a fee is paid during a bridging transaction.
    event FeePaid(uint256 amount);

    // Event emitted when a fee is paid during a bridging transaction.
    event GasFeeChanged(uint256 amount);

    // Event emitted when the bridge status (enabled/disabled) is toggled.
    event BridgeStatusChanged(bool status);

    // Modifier to ensure that the bridge is enabled before executing certain functions.
    modifier onlyWhenEnabled() {
        require(BRIDGE_ENABLED, "Bridge is not enabled");
        _;
    }

    /**
     * @dev Contract constructor. Initializes the `MESSAGE_OWNER` as the deploying address.
     */
    constructor() ERC20("WNETZ", "WNETZ") ERC20Permit("WNETZ") {
        MESSAGE_OWNER = msg.sender;
    }

    /**
     * @notice Bridges tokens to a destination chain.
     * @param _recipient The recipient address on the destination chain.
     * @param _amount The amount of WNETZ to bridge.
     * @param _destChainId The Chain ID of the destination chain.
     * @return txId The transaction ID of the cross-chain message.
     */
    function bridge(
        address _recipient,
        uint256 _amount,
        uint256 _destChainId
    )
        external
        payable
        onlyActiveChain(_destChainId)
        onlyWhenEnabled
        returns (uint256 txId)
    {
        require(_amount > 0, "Invalid amount");
        _burn(msg.sender, _amount);
        if (GAS_FEE > 0) {
            require(msg.value >= GAS_FEE, "Low gas fee");
            WETH.deposit{value: msg.value}();
        }
        uint256 _afterFee = takeFee(_amount);
        txId = _sendMessage(_destChainId, abi.encode(_recipient, _afterFee));
        emit Outgoing(msg.sender, _recipient, _afterFee);
    }

    /**
     * @notice Processes incoming messages from other chains.
     * @param _sourceChainId The ID of the source chain.
     * @param _sender The address of the sender on the source chain.
     * @param _data Encoded recipient address and token amount.
     * @dev must ensure contract is funded with gas to process at all times.
     */
    function messageProcess(
        uint256,
        uint256 _sourceChainId,
        address _sender,
        address,
        uint256,
        bytes calldata _data
    ) external override onlySelf(_sender, _sourceChainId) {
        (address recipient, uint256 amount) = abi.decode(
            _data,
            (address, uint256)
        );
        _mint(recipient, amount);
        emit Incoming(_sender, recipient, amount);
    }

    /**
     * @notice Sets additional gas fee required when bridging.
     * @param newFee The fee amount to charge for gas.
     */
    function setGasFee(uint256 newFee) external onlyMessageOwner {
        GAS_FEE = newFee;
        emit GasFeeChanged(newFee);
    }

    /**
     * @notice Changes the fee numerator.
     * @param newFee The new fee numerator.
     */
    function changeFeeNumerator(uint256 newFee) external onlyMessageOwner {
        require(newFee < FEE_DENOMINATOR, "Invalid fee");
        FEE_NUMERATOR = newFee;
        emit FeeChanged(newFee);
    }

    /**
     * @notice Toggles the bridge status (enabled/disabled).
     * @param status The new bridge status.
     */
    function toggleBridging(bool status) external onlyMessageOwner {
        BRIDGE_ENABLED = status;
        emit BridgeStatusChanged(status);
    }

    /**
     * @notice Retrieves the balance of the FEE_TOKEN held by the contract.
     * @return The FEE_TOKEN balance.
     */
    function feeTokenBalance() external view returns (uint256) {
        return FEE_TOKEN.balanceOf(address(this));
    }

    /**
     * @notice Retrieves the WETH balance of the contract.
     * @return The WETH balance.
     */
    function wethBalance() external view returns (uint256) {
        return WETH.balanceOf(address(this));
    }

    /**
     * @notice Retrieves the native currency balance of the contract.
     * @return The native balance.
     */
    function nativeBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Calculates the fee for a given amount.
     * @param amount The amount to calculate the fee for.
     * @return The calculated fee.
     */
    function calculateFee(uint256 amount) public view returns (uint256) {
        return (amount * FEE_NUMERATOR) / FEE_DENOMINATOR;
    }

    /**
     * @notice Deducts a fee from the specified amount.
     * @param amount The total amount to deduct the fee from.
     * @return afterFee The amount remaining after deducting the fee.
     */
    function takeFee(uint256 amount) internal returns (uint256 afterFee) {
        uint256 fee = calculateFee(amount);
        (bool success, ) = payable(MESSAGE_OWNER).call{value: fee}("");
        require(success, "Transfer failed");
        afterFee = amount - fee;
        emit FeePaid(fee);
    }
}
