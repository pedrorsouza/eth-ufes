// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/InterfaceAbstract.sol";

contract InterfaceAbstractTest is Test {
    SimpleWallet public wallet;
    address public user1;
    address public user2;

    function setUp() public {
        wallet = new SimpleWallet();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        console.log("=== Interface and Abstract Contract Tests ===");
    }

    function testInterfaceImplementation() view public {
        console.log("Testing interface implementation...");
        
        // Verificar que o contrato implementa a interface IWallet
        assertTrue(address(wallet) != address(0));
        console.log("Wallet contract deployed successfully");
    }

    function testDepositFunction() public {
        console.log("Testing deposit function...");
        
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();
        
        assertEq(wallet.balance(), 1 ether);
        console.log("Deposit successful, balance:", wallet.balance());
    }

    function testBalanceFunction() public {
        console.log("Testing balance function...");
        
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        wallet.deposit{value: 0.5 ether}();
        
        assertEq(wallet.balance(), 0.5 ether);
        console.log("Balance function working, amount:", wallet.balance());
    }

    function testGetBalanceFunction() public {
        console.log("Testing getBalance function (from abstract)...");
        
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        wallet.deposit{value: 1.5 ether}();
        
        assertEq(wallet.getBalance(), 1.5 ether);
        assertEq(wallet.balance(), wallet.getBalance());
        console.log("getBalance function working, amount:", wallet.getBalance());
    }

    function testMultipleDeposits() public {
        console.log("Testing multiple deposits...");
        
        vm.deal(user1, 3 ether);
        vm.deal(user2, 2 ether);
        
        // User1 deposita
        vm.prank(user1);
        wallet.deposit{value: 1 ether}();
        
        // User2 deposita
        vm.prank(user2);
        wallet.deposit{value: 0.5 ether}();
        
        assertEq(wallet.balance(), 1.5 ether);
        console.log("Multiple deposits successful, total balance:", wallet.balance());
    }

    function testZeroDeposit() public {
        console.log("Testing zero deposit rejection...");
        
        vm.deal(user1, 1 ether);
        
        // Tentar depositar 0 ETH
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("Error(string)", "zero"));
        wallet.deposit{value: 0}();
        
        console.log("Zero deposit correctly rejected");
    }

    function testAbstractForcesImplementation() public {
        console.log("Testing that abstract forces implementation...");
        
        // Verificar que todas as funções obrigatórias estão implementadas
        assertTrue(address(wallet) != address(0));
        
        // Testar que deposit() funciona (obrigatório da interface + abstract)
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        wallet.deposit{value: 0.3 ether}();
        
        // Testar que getBalance() funciona (obrigatório do abstract)
        assertEq(wallet.getBalance(), 0.3 ether);
        
        console.log("Abstract successfully forced implementation of all required functions");
        console.log("Balance from balance():", wallet.balance());
        console.log("Balance from getBalance():", wallet.getBalance());
    }

    function testInheritanceChain() public {
        console.log("Testing inheritance chain...");
        
        // Verificar que SimpleWallet herda de WalletBase que herda de IWallet
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        wallet.deposit{value: 0.8 ether}();
        
        // Todas as funções devem funcionar
        assertEq(wallet.balance(), 0.8 ether);
        assertEq(wallet.getBalance(), 0.8 ether);
        
        console.log("Inheritance chain working correctly");
        console.log("Interface -> Abstract -> Concrete implementation");
    }
}
