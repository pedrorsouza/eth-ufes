// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Variables {
    uint256 public number;
    uint256 internal number2;
    uint256 private number3;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function setNumber2(uint256 newNumber) public {
        number2 = newNumber;
    }

    function setNumber3(uint256 newNumber) public {
        number3 = newNumber;
    }

    /*/////////////////////////
            internal 
    /////////////////////////*/
    function getNumber2Internal() internal view returns (uint256) {
        return number2;
    }

    /*/////////////////////////
            public 
    /////////////////////////*/
    function getNumber3() public view returns (uint256) {
        return getNumber2Private();
    }

    /*/////////////////////////
            private 
    /////////////////////////*/
    function getNumber2Private() private view returns (uint256) {
        return number2;
    }

    /*/////////////////////////
            pure 
    /////////////////////////*/
    function getnumberOnePure() public pure returns (uint256) {
        uint256 numberOne = 1;
        return numberOne;
    }

    /*/////////////////////////
            payable 
    /////////////////////////*/
    function setPayAndSaveNumber() public payable {
        number = msg.value;
    }

    function getBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getGasPrice() public view returns (uint256) {
        return tx.gasprice;
    }

    function getAddress() public view returns (address) {
        return msg.sender;
    }
}
