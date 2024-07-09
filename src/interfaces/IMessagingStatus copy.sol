// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IStatusRead {
    /// @notice Flag indicating if staking is paused.
    function isTransferPaused() external view returns (bool);
    /// @notice Flag indicating if allocation is paused.
    function isOriginalMintBurnPaused() external view returns (bool);
}

interface IStatusWrite {
    /// @notice Update set TransferPaused status on local.
    function setIsTransferPaused(bool isPaused) external;
    /// @notice Update set TransferPaused status on target chain.
    function setIsTransferPausedFor(uint32 eid, bool isPaused, address toAddress) external payable;
    /// @notice Update set ExchangeRate on target chain.
    function setExchangeRateFor(uint32 _eid, uint256 rate, address _toAddress) external payable;
    /// @notice Update set Enable on target chain.
    function setEnableFor(uint32 _eid, bool _flag, address _toAddress) external payable;
    /// @notice Update set Bridging Capacity on target chain.
    function setCapFor(uint32 _eid, uint256 _cap, address _toAddress) external payable;

    /// @notice Emitted when a protocol bridging configuration has been updated.
    /// @param setterSelector The selector of the function that updated the configuration.
    /// @param setterSignature The signature of the function that updated the configuration.
    /// @param value The abi-encoded data passed to the function that updated the configuration. Since this event will
    /// only be emitted by setters, this data corresponds to the updated values in the protocol configuration.
    event BridgingConfigChanged(bytes4 indexed setterSelector, string setterSignature, bytes value);
}

interface IL1StatusWrite is IStatusWrite {
    /// @notice Update set OriginalMintBurnPaused status on local.
    function setIsOriginalMintBurnPaused(bool isPaused) external;
}

interface IMessagingStatus is IStatusRead, IStatusWrite, IL1StatusWrite {}

interface PauserEvents {
    /// @notice Emitted when a flag has been updated.
    /// @param selector The selector of the flag that was updated.
    /// @param isPaused The new value of the flag.
    /// @param flagName The name of the flag that was updated.
    event FlagUpdated(bytes4 indexed selector, bool indexed isPaused, string flagName);
}
