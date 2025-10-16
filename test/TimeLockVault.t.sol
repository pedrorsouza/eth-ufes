// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/projects/TimeLockVault.sol";

contract TimeLockVaultTest is Test {
    TimeLockVault public vault;
    address public user1;
    address public user2;
    address public user3;

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        vault = new TimeLockVault();

        console.log("=== TimeLockVault Contract Tests ===");
        console.log("User1:", user1);
        console.log("User2:", user2);
        console.log("User3:", user3);
        console.log("Min lock time:", vault.MIN_LOCK());
    }

    function testInitialState() public {
        console.log("Testing initial state...");

        assertEq(vault.MIN_LOCK(), 1 days);
        assertEq(vault.balances(user1), 0);
        assertEq(vault.balances(user2), 0);
        assertEq(vault.unlockTime(user1), 0);
        assertEq(vault.unlockTime(user2), 0);

        console.log("Initial state correct - all balances and unlock times are 0");
    }

    function testDeposit() public {
        console.log("Testing deposit functionality...");

        vm.deal(user1, 2 ether);
        uint256 initialBalance = user1.balance;
        uint256 lockTime = 2 days;

        vm.prank(user1);
        vault.deposit{value: 1 ether}(lockTime);

        assertEq(vault.balances(user1), 1 ether);
        assertEq(vault.unlockTime(user1), block.timestamp + lockTime);
        assertEq(user1.balance, initialBalance - 1 ether);

        console.log("Deposit successful - 1 ETH locked for 2 days");
        console.log("User balance after deposit:", user1.balance);
        console.log("Vault balance:", address(vault).balance);
        console.log("Unlock time:", vault.unlockTime(user1));
    }

    function testDepositZeroAmount() public {
        console.log("Testing deposit with zero amount...");

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("ZeroAmount()"));
        vault.deposit{value: 0}(1 days);

        console.log("Deposit correctly rejected with zero amount");
    }

    function testDepositLockTooShort() public {
        console.log("Testing deposit with lock time too short...");

        vm.deal(user1, 1 ether);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("LockTooShort()"));
        vault.deposit{value: 0.5 ether}(12 hours); // Less than 1 day

        console.log("Deposit correctly rejected with lock time too short");
    }

    function testDepositMultipleTimes() public {
        console.log("Testing multiple deposits by same user...");

        vm.deal(user1, 3 ether);

        // First deposit
        vm.prank(user1);
        vault.deposit{value: 1 ether}(2 days);

        // Second deposit with longer lock
        vm.prank(user1);
        vault.deposit{value: 1 ether}(3 days);

        assertEq(vault.balances(user1), 2 ether);
        assertEq(vault.unlockTime(user1), block.timestamp + 3 days);

        console.log("Multiple deposits successful - balance increased");
        console.log("Total balance:", vault.balances(user1));
        console.log("Unlock time extended to:", vault.unlockTime(user1));
    }

    function testDepositShorterLock() public {
        console.log("Testing deposit with shorter lock time...");

        vm.deal(user1, 2 ether);

        // First deposit with longer lock
        vm.prank(user1);
        vault.deposit{value: 1 ether}(3 days);

        uint256 firstUnlock = vault.unlockTime(user1);

        // Second deposit with shorter lock (should not change unlock time)
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);

        assertEq(vault.balances(user1), 2 ether);
        assertEq(vault.unlockTime(user1), firstUnlock); // Should remain the same

        console.log("Shorter lock deposit successful - unlock time unchanged");
        console.log("Unlock time remains:", vault.unlockTime(user1));
    }

    function testWithdrawBeforeUnlock() public {
        console.log("Testing withdrawal before unlock time...");

        vm.deal(user1, 2 ether);

        // Deposit with 2 days lock
        vm.prank(user1);
        vault.deposit{value: 1 ether}(2 days);

        // Try to withdraw immediately
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("NotUnlocked()"));
        vault.withdraw();

        console.log("Withdrawal correctly rejected before unlock time");
    }

    function testWithdrawAfterUnlock() public {
        console.log("Testing withdrawal after unlock time...");

        vm.deal(user1, 2 ether);

        // Deposit with 1 day lock
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);

        // Fast forward past unlock time
        vm.warp(block.timestamp + 1 days + 1);

        uint256 initialBalance = user1.balance;

        // Withdraw
        vm.prank(user1);
        vault.withdraw();

        assertEq(vault.balances(user1), 0);
        assertEq(user1.balance, initialBalance + 1 ether);
        assertEq(address(vault).balance, 0);

        console.log("Withdrawal successful after unlock time");
        console.log("User balance after withdrawal:", user1.balance);
    }

    function testWithdrawNoBalance() public {
        console.log("Testing withdrawal with no balance...");

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("NoBalance()"));
        vault.withdraw();

        console.log("Withdrawal correctly rejected with no balance");
    }

    function testNextUnlockOf() public {
        console.log("Testing nextUnlockOf function...");

        vm.deal(user1, 2 ether);

        // Deposit with 2 days lock
        vm.prank(user1);
        vault.deposit{value: 1 ether}(2 days);

        uint256 nextUnlock = vault.nextUnlockOf(user1);
        assertEq(nextUnlock, vault.unlockTime(user1));

        console.log("Next unlock time retrieved successfully");
        console.log("Next unlock:", nextUnlock);
    }

    function testMultipleUsers() public {
        console.log("Testing multiple users...");

        vm.deal(user1, 2 ether);
        vm.deal(user2, 2 ether);
        vm.deal(user3, 2 ether);

        // User1 deposits for 1 day
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);

        // User2 deposits for 2 days
        vm.prank(user2);
        vault.deposit{value: 1 ether}(2 days);

        // User3 deposits for 3 days
        vm.prank(user3);
        vault.deposit{value: 1 ether}(3 days);

        assertEq(vault.balances(user1), 1 ether);
        assertEq(vault.balances(user2), 1 ether);
        assertEq(vault.balances(user3), 1 ether);
        assertEq(address(vault).balance, 3 ether);

        console.log("Multiple users deposit successful");
        console.log("Total vault balance:", address(vault).balance);
    }

    function testCompleteFlow() public {
        console.log("Testing complete flow...");

        // 1. User deposits
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);
        console.log("Step 1: User deposited 1 ETH for 1 day");

        // 2. Wait for unlock
        vm.warp(block.timestamp + 1 days + 1);
        console.log("Step 2: Time passed, funds unlocked");

        // 3. User withdraws
        uint256 initialBalance = user1.balance;
        vm.prank(user1);
        vault.withdraw();
        console.log("Step 3: User withdrew funds");

        assertEq(user1.balance, initialBalance + 1 ether);
        assertEq(vault.balances(user1), 0);

        console.log("Complete flow successful!");
    }

    function testLockExtension() public {
        console.log("Testing lock extension...");

        vm.deal(user1, 3 ether);

        // First deposit with 1 day lock
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);
        uint256 firstUnlock = vault.unlockTime(user1);

        // Second deposit with 2 days lock (should extend)
        vm.prank(user1);
        vault.deposit{value: 1 ether}(2 days);
        uint256 secondUnlock = vault.unlockTime(user1);

        assertTrue(secondUnlock > firstUnlock);
        assertEq(vault.balances(user1), 2 ether);

        console.log("Lock extension successful");
        console.log("First unlock:", firstUnlock);
        console.log("Extended unlock:", secondUnlock);
    }

    function testReceiveFunction() public {
        console.log("Testing receive function...");

        vm.deal(address(this), 1 ether);

        vm.expectRevert("use deposit()");
        address(vault).call{value: 0.5 ether}("");

        console.log("Receive function correctly rejects direct ETH");
    }

    function testFallbackFunction() public {
        console.log("Testing fallback function...");

        vm.expectRevert("invalid call");
        address(vault).call(abi.encodeWithSignature("nonExistentFunction()"));

        console.log("Fallback function correctly rejects invalid calls");
    }

    function testMinLockConstant() public {
        console.log("Testing MIN_LOCK constant...");

        assertEq(vault.MIN_LOCK(), 1 days);
        console.log("MIN_LOCK constant:", vault.MIN_LOCK());
    }

    function testDepositExactMinLock() public {
        console.log("Testing deposit with exact minimum lock time...");

        vm.deal(user1, 1 ether);

        vm.prank(user1);
        vault.deposit{value: 0.5 ether}(1 days); // Exactly 1 day

        assertEq(vault.balances(user1), 0.5 ether);
        assertEq(vault.unlockTime(user1), block.timestamp + 1 days);

        console.log("Deposit with exact minimum lock successful");
    }

    function testWithdrawAfterMultipleDeposits() public {
        console.log("Testing withdrawal after multiple deposits...");

        vm.deal(user1, 3 ether);

        // Multiple deposits
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);

        vm.prank(user1);
        vault.deposit{value: 1 ether}(2 days);

        // Wait for unlock
        vm.warp(block.timestamp + 2 days + 1);

        uint256 initialBalance = user1.balance;

        // Withdraw all
        vm.prank(user1);
        vault.withdraw();

        assertEq(user1.balance, initialBalance + 2 ether);
        assertEq(vault.balances(user1), 0);

        console.log("Withdrawal after multiple deposits successful");
        console.log("Total withdrawn: 2 ETH");
    }

    function testTimeLockVaultBalance() public {
        console.log("Testing vault balance tracking...");

        vm.deal(user1, 2 ether);
        vm.deal(user2, 2 ether);

        // User1 deposits
        vm.prank(user1);
        vault.deposit{value: 1 ether}(1 days);

        // User2 deposits
        vm.prank(user2);
        vault.deposit{value: 1 ether}(2 days);

        assertEq(address(vault).balance, 2 ether);

        console.log("Vault balance tracking successful");
        console.log("Vault balance:", address(vault).balance);
    }
}
