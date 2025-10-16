// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Interface: apenas assinaturas (sem estado/implementacoes concretas)
interface IWallet {
    function deposit() external payable;
    function balance() external view returns (uint256);
}

// Abstract: pode ter implementação parcial; força filhos a completar
abstract contract WalletBase is IWallet {
    uint256 internal _bal; // estado protegido para filhos

    function balance() public view override returns (uint256) {
        return _bal;
    }

    // ✅ FORÇA filhos a implementar (não implementa aqui)
    // Obrigatório por: 1) Interface IWallet + 2) Abstract sem implementação
    function deposit() external payable virtual;

    // ✅ FORÇA filhos a implementar (função adicional do abstract)
    function getBalance() external view virtual returns (uint256);
}

// Implementação concreta que completa o que falta
contract SimpleWallet is WalletBase {
    event Deposited(address from, uint256 amount);

    function deposit() external payable override {
        require(msg.value > 0, "zero");
        _bal += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getBalance() external view override returns (uint256) {
        return _bal;
    }
}
