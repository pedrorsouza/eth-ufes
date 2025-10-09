// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Contrato "pai" com função virtual (pode ser sobrescrita)
contract Greeter {
    // 'virtual' permite que filhos mudem o comportamento
    function greet() public pure virtual returns (string memory) {
        return "Hello, World!";
    }
}

// Contrato "filho" que herda de Greeter e sobrescreve greet()
contract PTGreeter is Greeter {
    // 'override' declara que estamos sobrescrevendo a função do pai
    function greet() public pure override returns (string memory) {
        return "Ola, Mundo!";
    }
}