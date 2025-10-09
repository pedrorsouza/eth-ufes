// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ReceiveFallback.sol";

contract ReceiveFallbackTest is Test {
    ReceiveFallback public receiveFallback;
    address public user1;
    address public user2;
    address public owner;

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        owner = makeAddr("owner");
        vm.prank(owner);
        receiveFallback = new ReceiveFallback();
        console.log("=== ReceiveFallback Contract Tests ===");
    }

    function testReceiveFunction() public {
        console.log("Testing receive function...");
        
        // Enviar Ether diretamente para o contrato (chama receive)
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (bool success,) = address(receiveFallback).call{value: 0.5 ether}("");
        
        assertTrue(success);
        assertEq(receiveFallback.getBalance(), 0.5 ether);
        assertEq(receiveFallback.totalReceived(), 0.5 ether);
        assertEq(receiveFallback.receiveCalls(), 1);
        assertEq(receiveFallback.fallbackCalls(), 0);
        
        console.log("Receive function called successfully");
        console.log("Balance:", receiveFallback.getBalance());
        console.log("Total received:", receiveFallback.totalReceived());
    }

    function testFallbackFunction() public {
        console.log("Testing fallback function...");
        
        // Chamar função inexistente (chama fallback)
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (bool success,) = address(receiveFallback).call{value: 0.3 ether}(
            abi.encodeWithSignature("nonExistentFunction()")
        );
        
        assertTrue(success);
        assertEq(receiveFallback.getBalance(), 0.3 ether);
        assertEq(receiveFallback.totalReceived(), 0.3 ether);
        assertEq(receiveFallback.receiveCalls(), 0);
        assertEq(receiveFallback.fallbackCalls(), 1);
        
        console.log("Fallback function called successfully");
        console.log("Balance:", receiveFallback.getBalance());
        console.log("Fallback calls:", receiveFallback.fallbackCalls());
    }

    function testMultipleTransactions() public {
        console.log("Testing multiple transactions...");
        
        vm.deal(user1, 2 ether);
        vm.deal(user2, 1 ether);
        
        // User1 envia Ether (receive)
        vm.prank(user1);
        (bool success1,) = address(receiveFallback).call{value: 0.5 ether}("");
        assertTrue(success1);
        
        // User2 chama função inexistente (fallback)
        vm.prank(user2);
        (bool success2,) = address(receiveFallback).call{value: 0.3 ether}(
            abi.encodeWithSignature("fakeFunction()")
        );
        assertTrue(success2);
        
        // User1 envia mais Ether (receive)
        vm.prank(user1);
        (bool success3,) = address(receiveFallback).call{value: 0.2 ether}("");
        assertTrue(success3);
        
        assertEq(receiveFallback.getBalance(), 1 ether);
        assertEq(receiveFallback.totalReceived(), 1 ether);
        assertEq(receiveFallback.receiveCalls(), 2);
        assertEq(receiveFallback.fallbackCalls(), 1);
        
        console.log("Multiple transactions completed");
        console.log("Total balance:", receiveFallback.getBalance());
        console.log("Receive calls:", receiveFallback.receiveCalls());
        console.log("Fallback calls:", receiveFallback.fallbackCalls());
    }

    function testWithdrawFunction() public {
        console.log("Testing withdraw function...");
        
        // Enviar Ether para o contrato
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        (bool success,) = address(receiveFallback).call{value: 0.8 ether}("");
        assertTrue(success);
        
        uint256 initialBalance = owner.balance;
        uint256 contractBalance = receiveFallback.getBalance();
        
        // User1 retira o Ether
        vm.prank(owner);
        receiveFallback.withdraw();
        
        assertEq(receiveFallback.getBalance(), 0);
        assertEq(owner.balance, initialBalance + contractBalance);
        
        console.log("Withdraw successful");
        console.log("Contract balance after withdraw:", receiveFallback.getBalance());
        console.log("User balance after withdraw:", owner.balance);
    }

    function testStatsFunction() public {
        console.log("Testing stats function...");
        
        vm.deal(user1, 1 ether);
        
        // Fazer algumas transações
        vm.prank(user1);
        (bool success1,) = address(receiveFallback).call{value: 0.4 ether}("");
        assertTrue(success1);
        
        vm.prank(user1);
        (bool success2,) = address(receiveFallback).call{value: 0.2 ether}(
            abi.encodeWithSignature("testFunction()")
        );
        assertTrue(success2);
        
        (uint256 totalReceived, uint256 receiveCalls, uint256 fallbackCalls) = receiveFallback.getStats();
        
        assertEq(totalReceived, 0.6 ether);
        assertEq(receiveCalls, 1);
        assertEq(fallbackCalls, 1);
        
        console.log("Stats function working correctly");
        console.log("Total received:", totalReceived);
        console.log("Receive calls:", receiveCalls);
        console.log("Fallback calls:", fallbackCalls);
    }

    function testReceiveVsFallback() public {
        console.log("Testing receive vs fallback behavior...");
        
        vm.deal(user1, 2 ether);
        
        // Transação simples (deve chamar receive)
        vm.prank(user1);
        (bool success1,) = address(receiveFallback).call{value: 0.5 ether}("");
        assertTrue(success1);
        
        // Transação com dados (deve chamar fallback)
        vm.prank(user1);
        (bool success2,) = address(receiveFallback).call{value: 0.3 ether}(
            abi.encodeWithSignature("someFunction(uint256)", 123)
        );
        assertTrue(success2);
        
        assertEq(receiveFallback.receiveCalls(), 1);
        assertEq(receiveFallback.fallbackCalls(), 1);
        assertEq(receiveFallback.totalReceived(), 0.8 ether);
        
        console.log("Receive vs fallback behavior confirmed");
        console.log("Receive calls (simple transfer):", receiveFallback.receiveCalls());
        console.log("Fallback calls (with data):", receiveFallback.fallbackCalls());
    }
}
