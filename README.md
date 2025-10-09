# Ethereum Smart Contracts - Educational Repository

## 🎓 About This Repository

This repository is designed for **educational purposes** for students at **UFES (Universidade Federal do Espírito Santo)**. It contains comprehensive examples and implementations of Solidity smart contracts, covering fundamental concepts, security patterns, and best practices in blockchain development.

## 📚 Learning Objectives

This repository demonstrates:

- **Basic Solidity Concepts**: Variables, functions, visibility modifiers
- **Advanced Patterns**: Interfaces, abstract contracts, inheritance
- **Security Concepts**: Reentrancy attacks and protection mechanisms
- **Testing**: Comprehensive test suites with Foundry
- **Best Practices**: Code organization, error handling, and gas optimization

## 🏗️ Repository Structure

```
src/
├── Functions.sol              # Function visibility and modifiers
├── Variables.sol              # Variable types and scopes
├── ReceiveFallback.sol        # Receive and fallback functions
├── InterfaceAbstract.sol      # Interfaces and abstract contracts
├── projects/
│   └── SafePiggy.sol          # Contract with security patterns
└── ReentrancyAttacker.sol     # Malicious contract for testing

test/
├── Functions.t.sol            # Tests for function concepts
├── Variables.t.sol            # Tests for variable concepts
├── ReceiveFallback.t.sol      # Tests for receive/fallback
├── InterfaceAbstract.t.sol   # Tests for interfaces/abstract
└── SafePiggy.t.sol           # Comprehensive security tests
```

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd eth-ufes

# Install dependencies
forge install

# Build the project
forge build
```

## 🧪 Running Tests

### Run All Tests
```bash
forge test
```

### Run Specific Test Suites
```bash
# Test basic functions
forge test --match-contract FunctionsTest

# Test variables
forge test --match-contract VariablesTest

# Test receive/fallback
forge test --match-contract ReceiveFallbackTest

# Test interfaces and abstract contracts
forge test --match-contract InterfaceAbstractTest

# Test security patterns
forge test --match-contract SafePiggyTest
```

### Run Tests with Verbose Output
```bash
forge test -vv
```

## 📖 Educational Content

### 1. **Function Visibility and Modifiers** (`Functions.sol`)
- **Public, Internal, Private** functions
- **Pure vs View** functions
- **Payable** functions
- **Blockchain data** access (block.timestamp, msg.sender, etc.)

### 2. **Variable Scopes** (`Variables.sol`)
- **Public, Internal, Private** variables
- **State variables** vs **local variables**
- **Storage** vs **memory** vs **calldata**

### 3. **Receive and Fallback Functions** (`ReceiveFallback.sol`)
- **Receive()** function for direct ETH transfers
- **Fallback()** function for unknown function calls
- **Event logging** for transaction tracking

### 4. **Interfaces and Abstract Contracts** (`InterfaceAbstract.sol`)
- **Interface** definition and implementation
- **Abstract contracts** forcing child implementation
- **Inheritance** patterns
- **Virtual** and **override** keywords

### 5. **Security Patterns** (`SafePiggy.sol`)
- **Reentrancy protection** with modifiers
- **Pull over Push** pattern
- **CEI pattern** (Checks-Effects-Interactions)
- **Custom errors** for gas optimization
- **Access control** with owner patterns

### 6. **Reentrancy Attack Demonstration** (`ReentrancyAttacker.sol`)
- **Malicious contract** for testing
- **Real reentrancy attack** implementation
- **Vulnerable vs Secure** function comparison

## 🔒 Security Concepts Demonstrated

### Reentrancy Attack Protection
The repository includes a comprehensive demonstration of reentrancy attacks:

- **Vulnerable Function**: `pullAttack()` - demonstrates how NOT to implement
- **Secure Function**: `pull()` - demonstrates proper protection
- **Attack Simulation**: Shows how malicious contracts can drain funds
- **Protection Mechanisms**: `noReentrancy` modifier and CEI pattern

### Test Results
```
✅ Secure function: Only authorized amount withdrawn
🚨 Vulnerable function: Complete contract drainage possible
```

## 🛠️ Development Commands

### Build and Compile
```bash
# Build all contracts
forge build

# Build specific contract
forge build --contracts src/SafePiggy.sol
```

### Testing
```bash
# Run all tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Run specific test
forge test --match-test testReentrancyAttack

# Run tests with detailed traces
forge test -vvv
```

### Code Quality
```bash
# Format code
forge fmt

# Lint code
forge lint

# Generate gas snapshots
forge snapshot
```

### Local Development
```bash
# Start local blockchain
anvil

# Deploy contracts
forge script script/Counter.s.sol:CounterScript --rpc-url http://localhost:8545
```

## 📊 Test Coverage

All contracts include comprehensive test suites:

- **Function Tests**: 8/8 passing
- **Variable Tests**: 6/6 passing  
- **Receive/Fallback Tests**: 6/6 passing
- **Interface/Abstract Tests**: 8/8 passing
- **Security Tests**: 11/11 passing

**Total: 39/39 tests passing** ✅

## 🎯 Learning Path

### Beginner Level
1. Start with `Variables.sol` and `Variables.t.sol`
2. Move to `Functions.sol` and `Functions.t.sol`
3. Understand `ReceiveFallback.sol` concepts

### Intermediate Level
4. Study `InterfaceAbstract.sol` patterns
5. Analyze inheritance and polymorphism
6. Practice with test implementations

### Advanced Level
7. Deep dive into `SafePiggy.sol` security patterns
8. Understand reentrancy attacks and protection
9. Study `ReentrancyAttacker.sol` malicious patterns

## 🤝 Contributing

This repository is for educational purposes. Students are encouraged to:

- **Experiment** with the code
- **Add new examples** and test cases
- **Improve documentation** and comments
- **Create additional security patterns**

## 📚 Additional Resources

- [Solidity Documentation](https://docs.soliditylang.org/)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Consensys Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)

## 🏫 UFES Blockchain Education

This repository supports the blockchain and smart contract curriculum at UFES, providing hands-on examples and real-world security patterns for students to learn and practice.

---

**Happy Learning! 🚀**

*For questions or suggestions, please contact the course instructors.*