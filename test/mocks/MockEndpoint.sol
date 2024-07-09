// SPDX-License-Identifier: LZBL-1.2

pragma solidity ^0.8.20;

contract EndpointV2 {
    mapping(address oapp => address delegate) public delegates;

    /// @param _eid the unique Endpoint Id for this deploy that all other Endpoints can use to send to it
    constructor(uint32 _eid, address _owner) {}

    /// @notice delegate is authorized by the oapp to configure anything in layerzero
    function setDelegate(address _delegate) external {
        delegates[msg.sender] = _delegate;
    }
}
