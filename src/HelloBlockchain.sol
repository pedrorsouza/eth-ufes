// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title smart contract to say hello to the blockchain
/// @author @Afonsodalvi
/// @custom:experimental This is an experimental contract
contract HelloBlockchain {
    string public message;

    constructor(string memory _message) {
        message = _message;
    }

    /// @notice This function allows you to set a message
    /// @dev This function allows you to set a message
    /// @param _newMessage The new message
    function setMessage(string memory _newMessage) public {
        message = _newMessage;
    }
}
