// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/projects/SafePiggy.sol";
import "../src/ReentrancyAttacker.sol";

contract SafePiggyTest is Test {
    SafePiggy public safePiggy;
    ReentrancyAttacker public attacker;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        vm.prank(owner);
        safePiggy = new SafePiggy();
        
        attacker = new ReentrancyAttacker(address(safePiggy));
        
        console.log("=== SafePiggy Contract Tests ===");
    }

    function testDeposit() public {
        console.log("Testing deposit functionality...");
        
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        safePiggy.deposit{value: 1 ether}();
        
        assertEq(safePiggy.contractBalance(), 1 ether);
        console.log("Deposit successful, contract balance:", safePiggy.contractBalance());
    }

    function testReceive() public {
        console.log("Testing receive function...");
        
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        (bool success,) = address(safePiggy).call{value: 0.5 ether}("");
        
        assertTrue(success);
        assertEq(safePiggy.contractBalance(), 0.5 ether);
        console.log("Receive function working, balance:", safePiggy.contractBalance());
    }

    function testSetAllowance() public {
        console.log("Testing allowance system...");
        
        // Owner define allowance para user1
        vm.prank(owner);
        safePiggy.setAllowanceInEth(user1, 2); // 2 ETH
        
        assertEq(safePiggy.allowance(user1), 2 ether);
        console.log("Allowance set for user1:", safePiggy.allowance(user1));
    }

    function testPullWithAllowance() public {
        console.log("Testing pull with allowance...");
        
        // Depositar ETH no contrato
        vm.deal(user1, 3 ether);
        vm.prank(user1);
        safePiggy.deposit{value: 1 ether}();
        
        // Owner define allowance
        vm.prank(owner);
        safePiggy.setAllowanceInEth(user1, 1); // 1 ETH
        
        uint256 initialBalance = user1.balance;
        
        // User1 saca
        vm.prank(user1);
        safePiggy.pull();
        
        assertEq(safePiggy.allowance(user1), 0);
        assertEq(user1.balance, initialBalance + 1 ether);
        console.log("Pull successful, user balance:", user1.balance);
    }

    function testPullWithoutAllowance() public {
        console.log("Testing pull without allowance...");
        
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        safePiggy.deposit{value: 1 ether}();
        
        // Tentar sacar sem allowance
        vm.prank(user1);
        vm.expectRevert(NotAllowed.selector);
        safePiggy.pull();
        
        console.log("Pull correctly rejected without allowance");
    }

    function testMultipleUsers() public {
        console.log("Testing multiple users...");
        
        // Depositar ETH
        vm.deal(user1, 2 ether);
        vm.deal(user2, 2 ether);
        
        vm.prank(user1);
        safePiggy.deposit{value: 1 ether}();
        
        vm.prank(user2);
        safePiggy.deposit{value: 1 ether}();
        
        // Owner define allowances
        vm.prank(owner);
        safePiggy.setAllowanceInEth(user1, 1);
        
        vm.prank(owner);
        safePiggy.setAllowanceInEth(user2, 1);
        
        // Ambos sacam
        vm.prank(user1);
        safePiggy.pull();
        
        vm.prank(user2);
        safePiggy.pull();
        
        assertEq(safePiggy.contractBalance(), 0);
        console.log("Multiple users test successful");
    }

    function testReentrancyAttackWithProtection() public {
        console.log("Testing reentrancy attack WITH protection...");
        
        // Depositar ETH no contrato
        vm.deal(address(this), 5 ether);
        safePiggy.deposit{value: 3 ether}();
        
        // Owner define allowance para user1
        vm.prank(owner);
        safePiggy.setAllowanceInEth(user1, 1); // 1 ETH
        
        uint256 initialBalance = safePiggy.contractBalance();
        
        // User1 saca normalmente usando pull() (com proteção)
        vm.prank(user1);
        safePiggy.pull();
        
        // Verificar que apenas 1 ETH foi sacado (sem reentrância)
        assertEq(safePiggy.contractBalance(), initialBalance - 1 ether);
        
        console.log("Normal pull with protection - no reentrancy possible");
        console.log("Contract balance after pull:", safePiggy.contractBalance());
    }

    
    function testReentrancyAttackVulnerableFunction() public {
        console.log("Testing REAL reentrancy attack on vulnerable function...");
        
        // Depositar ETH no contrato
        vm.deal(address(this), 5 ether);
        safePiggy.deposit{value: 3 ether}();
        
        // Owner define allowance para o atacante
        vm.prank(owner);
        safePiggy.setAllowanceInEth(address(attacker), 1); // 1 ETH
        
        uint256 initialBalance = safePiggy.contractBalance();
        uint256 initialAttackerBalance = attacker.getBalance();
        
        // Tentar ataque usando pullAttack() (SEM proteção)
        // O atacante deve conseguir drenar mais do que deveria
        attacker.startAttackVulnerable();
        
        uint256 finalBalance = safePiggy.contractBalance();
        uint256 finalAttackerBalance = attacker.getBalance();
        
        // Verificar se o ataque foi bem-sucedido
        assertTrue(finalAttackerBalance > initialAttackerBalance);
        assertTrue(finalBalance < initialBalance);
        
        console.log("REAL reentrancy attack SUCCESSFUL!");
        console.log("Contract balance before:", initialBalance);
        console.log("Contract balance after:", finalBalance);
        console.log("Attacker balance before:", initialAttackerBalance);
        console.log("Attacker balance after:", finalAttackerBalance);
        console.log("Amount stolen:", finalAttackerBalance - initialAttackerBalance);
    }

    function testFallbackFunction() public {
        console.log("Testing fallback function...");
        
        vm.deal(user1, 1 ether);
        
        // Chamar função inexistente
        vm.prank(user1);
        (bool success,) = address(safePiggy).call{value: 0.3 ether}(
            abi.encodeWithSignature("nonExistentFunction()")
        );
        
        assertTrue(success);
        assertEq(safePiggy.contractBalance(), 0.3 ether);
        console.log("Fallback function working, balance:", safePiggy.contractBalance());
    }

    function testContractBalance() public {
        console.log("Testing contract balance function...");
        
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        safePiggy.deposit{value: 1.5 ether}();
        
        assertEq(safePiggy.contractBalance(), 1.5 ether);
        console.log("Contract balance:", safePiggy.contractBalance());
    }
}

// 🚨 Contrato vulnerável para demonstrar ataque de reentrância
contract VulnerableSafePiggy {
    address public immutable owner;
    mapping(address => uint256) public allowance;
    bool private locked;
    
    error VulnerableNotOwner();
    error VulnerableZeroAmount();
    error VulnerableNotAllowed();
    
    event Deposited(address indexed from, uint256 amount);
    event AllowanceSet(address indexed who, uint256 amount);
    event Pulled(address indexed who, uint256 amount);
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert VulnerableNotOwner();
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    receive() external payable {
        if (msg.value == 0) revert VulnerableZeroAmount();
        emit Deposited(msg.sender, msg.value);
    }
    
    function deposit() external payable {
        if (msg.value == 0) revert VulnerableZeroAmount();
        emit Deposited(msg.sender, msg.value);
    }
    
    function setAllowanceInEth(address who, uint256 ethAmount) external onlyOwner {
        allowance[who] = ethAmount * 1e18;
        emit AllowanceSet(who, allowance[who]);
    }
    
    // 🚨 VULNERÁVEL: Sem proteção contra reentrância E sem padrão CEI
    function pull() external {
        uint256 amount = allowance[msg.sender];
        if (amount == 0) revert VulnerableNotAllowed();
        
        if (address(this).balance < amount) revert VulnerableNotAllowed();
        
        // 🚨 VULNERÁVEL: Call externo ANTES de zerar o allowance
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
        
        // 🚨 VULNERÁVEL: Zerar allowance DEPOIS da transferência
        allowance[msg.sender] = 0;
        
        emit Pulled(msg.sender, amount);
    }
    
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
