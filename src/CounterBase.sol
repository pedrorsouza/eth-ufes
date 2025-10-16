// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract CounterBase {
    uint256 internal _count; // 'internal' para filhos acessarem

    // Construtor do "pai" aceita um valor inicial
    constructor(uint256 initial) {
        _count = initial;
    }

    // Função virtual para ser customizada no filho
    function inc() public virtual {
        _count += 1;
    }

    function current() public view returns (uint256) {
        return _count;
    }
}

contract CounterX2 is CounterBase {
    // Encadeia o construtor do pai: 'CounterBase(_initial * 2)'
    constructor(uint256 _initial) CounterBase(_initial * 2) {}

    // Sobrescreve 'inc' para pular de 2 em 2
    function inc() public override {
        _count += 2;
    }
}
