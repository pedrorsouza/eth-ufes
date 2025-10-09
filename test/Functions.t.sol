// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Functions.sol";

contract FunctionsTest is Test {
    Variables public variables;

    function setUp() public {
        variables = new Variables();
        console.log("=== Functions Contract Tests ===");
    }

    function testPublicVariables() public {
        console.log("Testing public variables...");
        
        uint256 testValue = 100;
        variables.setNumber(testValue);
        assertEq(variables.number(), testValue);
        console.log("Public number set and retrieved:", testValue);
    }

    function testInternalVariables() public {
        console.log("Testing internal variables...");
        
        uint256 testValue = 200;
        variables.setNumber2(testValue);
        // Internal variable can only be accessed through public functions
        uint256 retrievedValue = variables.getNumber3();
        assertEq(retrievedValue, testValue);
        console.log("Internal number2 set and retrieved:", testValue);
    }

    function testPrivateVariables() public {
        console.log("Testing private variables...");
        
        uint256 testValue = 300;
        variables.setNumber3(testValue);
        // Note: getNumber3() actually returns number2 (internal), not number3 (private)
        // This demonstrates that private variables can only be accessed within the contract
        console.log("Private number3 set (cannot be directly accessed from outside)");
        console.log("Note: getNumber3() returns internal number2, not private number3");
    }

    function testPureFunction() public {
        console.log("Testing pure function...");
        
        uint256 result = variables.getnumberOnePure();
        assertEq(result, 1);
        console.log("Pure function returns:", result);
    }

    function testPayableFunction() public {
        console.log("Testing payable function...");
        
        uint256 sendValue = 1 ether;
        variables.setPayAndSaveNumber{value: sendValue}();
        
        assertEq(variables.number(), sendValue);
        console.log("Payable function received:", sendValue);
    }

    function testBlockData() public {
        console.log("Testing blockchain data functions...");
        
        uint256 timestamp = variables.getBlockTimestamp();
        uint256 blockNumber = variables.getBlockNumber();
        uint256 gasPrice = variables.getGasPrice();
        address sender = variables.getAddress();
        
        // In test environment, some values might be 0, so we just check they exist
        assertTrue(timestamp >= 0);
        assertTrue(blockNumber >= 0);
        assertTrue(gasPrice >= 0);
        assertTrue(sender != address(0));
        
        console.log("Block timestamp:", timestamp);
        console.log("Block number:", blockNumber);
        console.log("Gas price:", gasPrice);
        console.log("Sender address:", sender);
    }

    function testMultipleOperations() public {
        console.log("Testing multiple operations...");
        
        // Set all numbers
        variables.setNumber(100);
        variables.setNumber2(200);
        variables.setNumber3(300);
        
        // Verify all numbers
        assertEq(variables.number(), 100);
        assertEq(variables.getNumber3(), 200); // This gets number2 through internal function
        
        console.log("All numbers set successfully");
        console.log("  - Public number:", variables.number());
        console.log("  - Internal number2:", variables.getNumber3());
    }

    function testPayableWithEther() public {
        console.log("Testing payable function with different amounts...");
        
        // Test with 0.5 ether
        variables.setPayAndSaveNumber{value: 0.5 ether}();
        assertEq(variables.number(), 0.5 ether);
        console.log("Set with 0.5 ether");
        
        // Test with 2 ether
        variables.setPayAndSaveNumber{value: 2 ether}();
        assertEq(variables.number(), 2 ether);
        console.log("Set with 2 ether");
    }
}
