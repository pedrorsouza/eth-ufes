// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract ReceiveFallback {
    uint256 public totalReceived;
    uint256 public fallbackCalls;
    uint256 public receiveCalls;
    
    address public owner;
    event EtherReceived(address sender, uint256 amount);
    event FallbackCalled(address sender, uint256 amount, bytes data);
    error NoEtherToWithdraw();
    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }
    
    // Função receive - chamada quando Ether é enviado diretamente para o contrato
    receive() external payable {
        totalReceived += msg.value;
        receiveCalls++;
        emit EtherReceived(msg.sender, msg.value);
    }
    
    // Função fallback - chamada quando:
    // 1. Ether é enviado e não há função receive
    // 2. Função inexistente é chamada
    fallback() external payable {
        totalReceived += msg.value;
        fallbackCalls++;
        emit FallbackCalled(msg.sender, msg.value, msg.data);
    }
    
    // Função para retirar Ether do contrato
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) {
            revert NoEtherToWithdraw();
        }
        
        payable(msg.sender).transfer(balance);
    }
    
    // Função para obter o saldo do contrato
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // Função para obter estatísticas
    function getStats() external view returns (uint256, uint256, uint256) {
        return (totalReceived, receiveCalls, fallbackCalls);
    }
}
