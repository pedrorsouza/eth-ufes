// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/projects/Escrow.sol";

contract EscrowTest is Test {
    SimpleEscrow public escrow;
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public PRICE = 1 ether;

    function setUp() public {
        buyer = makeAddr("buyer");
        seller = makeAddr("seller");
        arbiter = makeAddr("arbiter");

        escrow = new SimpleEscrow(buyer, seller, arbiter, PRICE);

        console.log("=== Escrow Contract Tests ===");
        console.log("Buyer:", buyer);
        console.log("Seller:", seller);
        console.log("Arbiter:", arbiter);
        console.log("Price:", PRICE);
    }

    function testInitialState() public {
        console.log("Testing initial state...");

        assertEq(escrow.BUYER(), buyer);
        assertEq(escrow.SELLER(), seller);
        assertEq(escrow.ARBITER(), arbiter);
        assertEq(escrow.PRICE(), PRICE);
        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.AwaitingDeposit));
        assertEq(escrow.timeLimit(), 30 days);

        console.log("Initial state correct - AwaitingDeposit");
    }

    function testDeposit() public {
        console.log("Testing deposit functionality...");

        vm.deal(buyer, 2 ether);
        uint256 initialBalance = buyer.balance;

        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.Deposited));
        assertEq(buyer.balance, initialBalance - PRICE);
        assertEq(address(escrow).balance, PRICE);
        assertEq(escrow.timeLastDeposit(buyer), block.timestamp);

        console.log("Deposit successful - state changed to Deposited");
        console.log("Contract balance:", address(escrow).balance);
    }

    function testDepositWrongAmount() public {
        console.log("Testing deposit with wrong amount...");

        vm.deal(buyer, 2 ether);

        vm.prank(buyer);
        vm.expectRevert(abi.encodeWithSignature("WrongAmount()"));
        escrow.deposit{value: 0.5 ether}();

        console.log("Deposit correctly rejected with wrong amount");
    }

    function testDepositNotBuyer() public {
        console.log("Testing deposit by non-buyer...");

        vm.deal(seller, 2 ether);

        vm.prank(seller);
        vm.expectRevert(abi.encodeWithSignature("NotBuyer()"));
        escrow.deposit{value: PRICE}();

        console.log("Deposit correctly rejected by non-buyer");
    }

    function testDepositWrongState() public {
        console.log("Testing deposit in wrong state...");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        // Tentar depositar novamente
        vm.prank(buyer);
        vm.expectRevert(abi.encodeWithSignature("InvalidState()"));
        escrow.deposit{value: PRICE}();

        console.log("Deposit correctly rejected in wrong state");
    }

    function testApproveRelease() public {
        console.log("Testing arbiter approval...");

        // Setup: buyer deposits
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        uint256 initialSellerBalance = seller.balance;

        // Arbiter approves
        vm.prank(arbiter);
        escrow.approveRelease();

        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.Released));
        assertEq(escrow.pending(seller), PRICE);

        console.log("Approval successful - state changed to Released");
        console.log("Seller pending balance:", escrow.pending(seller));
    }

    function testApproveReleaseNotArbiter() public {
        console.log("Testing approval by non-arbiter...");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        vm.prank(buyer);
        vm.expectRevert(abi.encodeWithSignature("NotArbiter()"));
        escrow.approveRelease();

        console.log("Approval correctly rejected by non-arbiter");
    }

    function testApproveReleaseAfterTimeLimit() public {
        console.log("Testing approval after time limit...");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        // Fast forward past time limit
        vm.warp(block.timestamp + 31 days);

        vm.prank(arbiter);
        vm.expectRevert(abi.encodeWithSignature("TimeLimitExceeded()"));
        escrow.approveRelease();

        console.log("Approval correctly rejected after time limit");
    }

    function testRefundBuyer() public {
        console.log("Testing arbiter refund...");

        // Setup: buyer deposits
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        // Arbiter refunds
        vm.prank(arbiter);
        escrow.refundBuyer();

        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.Refunded));
        assertEq(escrow.pending(buyer), PRICE);

        console.log("Refund successful - state changed to Refunded");
        console.log("Buyer pending balance:", escrow.pending(buyer));
    }

    function testRefundBuyerAfterTimeLimit() public {
        console.log("Testing refund after time limit (should work)...");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        // Fast forward past time limit
        vm.warp(block.timestamp + 31 days);

        // Refund should still work
        vm.prank(arbiter);
        escrow.refundBuyer();

        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.Refunded));
        console.log("Refund successful even after time limit");
    }

    function testCancelByBuyer() public {
        console.log("Testing buyer cancellation...");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        uint256 initialBalance = buyer.balance;

        // Buyer cancels
        vm.prank(buyer);
        escrow.cancel();

        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.Cancelled));
        assertEq(buyer.balance, initialBalance + PRICE);
        assertEq(address(escrow).balance, 0);

        console.log("Cancellation successful - buyer received funds");
        console.log("Buyer balance after cancel:", buyer.balance);
    }

    function testCancelNotBuyer() public {
        console.log("Testing cancellation by non-buyer...");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        vm.prank(seller);
        vm.expectRevert(abi.encodeWithSignature("NotBuyer()"));
        escrow.cancel();

        console.log("Cancellation correctly rejected by non-buyer");
    }

    function testWithdraw() public {
        console.log("Testing withdrawal functionality...");

        // Setup: buyer deposits and arbiter approves
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        vm.prank(arbiter);
        escrow.approveRelease();

        uint256 initialSellerBalance = seller.balance;

        // Seller withdraws
        vm.prank(seller);
        escrow.withdraw();

        assertEq(seller.balance, initialSellerBalance + PRICE);
        assertEq(escrow.pending(seller), 0);

        console.log("Withdrawal successful - seller received funds");
        console.log("Seller balance after withdraw:", seller.balance);
    }

    function testWithdrawNothing() public {
        console.log("Testing withdrawal with no pending balance...");

        vm.prank(seller);
        vm.expectRevert(abi.encodeWithSignature("NothingToWithdraw()"));
        escrow.withdraw();

        console.log("Withdrawal correctly rejected - no pending balance");
    }

    function testStatusFunction() public {
        console.log("Testing status function...");

        assertEq(escrow.status(), "AwaitingDeposit");

        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();

        assertEq(escrow.status(), "Deposited");

        vm.prank(arbiter);
        escrow.approveRelease();

        assertEq(escrow.status(), "Released");

        console.log("Status function working correctly");
    }

    function testCompleteFlow() public {
        console.log("Testing complete escrow flow...");

        // 1. Buyer deposits
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();
        console.log("Step 1: Buyer deposited");

        // 2. Arbiter approves
        vm.prank(arbiter);
        escrow.approveRelease();
        console.log("Step 2: Arbiter approved");

        // 3. Seller withdraws
        uint256 initialSellerBalance = seller.balance;
        vm.prank(seller);
        escrow.withdraw();
        console.log("Step 3: Seller withdrew");

        assertEq(seller.balance, initialSellerBalance + PRICE);
        assertEq(address(escrow).balance, 0);

        console.log("Complete flow successful!");
    }

    function testRefundFlow() public {
        console.log("Testing refund flow...");

        // 1. Buyer deposits
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();
        console.log("Step 1: Buyer deposited");

        // 2. Arbiter refunds
        vm.prank(arbiter);
        escrow.refundBuyer();
        console.log("Step 2: Arbiter refunded");

        // 3. Buyer withdraws
        uint256 initialBuyerBalance = buyer.balance;
        vm.prank(buyer);
        escrow.withdraw();
        console.log("Step 3: Buyer withdrew");

        assertEq(buyer.balance, initialBuyerBalance + PRICE);
        assertEq(address(escrow).balance, 0);

        console.log("Refund flow successful!");
    }

    function testCancelFlow() public {
        console.log("Testing cancellation flow...");

        // 1. Buyer deposits
        vm.deal(buyer, 2 ether);
        vm.prank(buyer);
        escrow.deposit{value: PRICE}();
        console.log("Step 1: Buyer deposited");

        // 2. Buyer cancels
        uint256 initialBuyerBalance = buyer.balance;
        vm.prank(buyer);
        escrow.cancel();
        console.log("Step 2: Buyer cancelled");

        assertEq(buyer.balance, initialBuyerBalance + PRICE);
        assertEq(address(escrow).balance, 0);
        assertEq(uint256(escrow.state()), uint256(SimpleEscrow.State.Cancelled));

        console.log("Cancellation flow successful!");
    }

    function testReceiveFunction() public {
        console.log("Testing receive function...");

        vm.deal(address(this), 1 ether);

        // Test that receive function reverts with correct message
        vm.expectRevert("use deposit()");
        (bool success,) = address(escrow).call{value: 0.5 ether}("");
        assertTrue(success);

        console.log("Receive function correctly rejects direct ETH");
    }

    function testFallbackFunction() public {
        console.log("Testing fallback function...");

        // Test that fallback function reverts with correct message
        vm.expectRevert("invalid call");
        (bool success,) = address(escrow).call(abi.encodeWithSignature("nonExistentFunction()"));
        assertTrue(success);

        console.log("Fallback function correctly rejects invalid calls");
    }
}
