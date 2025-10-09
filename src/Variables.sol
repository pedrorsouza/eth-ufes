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

    function getNumber2() public view returns (uint256) {
        return number2;
    }

    function getNumber3() public view returns (uint256) {
        return number3;
    }
}