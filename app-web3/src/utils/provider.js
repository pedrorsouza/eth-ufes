import { ethers } from 'ethers';
import { config } from '../config/index.js';

/**
 * Classe para gerenciar conexões com a blockchain
 */
export class ProviderManager {
  constructor() {
    this.provider = null;
    this.wallet = null;
    this.signer = null;
  }

  /**
   * Inicializa o provider e wallet
   * @param {string} rpcUrl - URL do RPC
   * @param {string} privateKey - Chave privada (opcional)
   */
  async initialize(rpcUrl = config.rpcUrl, privateKey = config.privateKey) {
    try {
      // Cria o provider
      this.provider = new ethers.JsonRpcProvider(rpcUrl);
      
      // Verifica a conexão
      const network = await this.provider.getNetwork();
      console.log(`Conectado à rede: ${network.name} (Chain ID: ${network.chainId})`);
      
      // Se uma chave privada foi fornecida, cria o wallet
      if (privateKey) {
        this.wallet = new ethers.Wallet(privateKey, this.provider);
        this.signer = this.wallet;
        console.log(`Wallet conectado: ${this.wallet.address}`);
      }
      
      return true;
    } catch (error) {
      console.error('Erro ao inicializar provider:', error);
      throw error;
    }
  }

  /**
   * Obtém o provider atual
   */
  getProvider() {
    if (!this.provider) {
      throw new Error('Provider não inicializado. Chame initialize() primeiro.');
    }
    return this.provider;
  }

  /**
   * Obtém o signer atual
   */
  getSigner() {
    if (!this.signer) {
      throw new Error('Signer não disponível. Forneça uma chave privada.');
    }
    return this.signer;
  }

  /**
   * Obtém o endereço do wallet
   */
  getAddress() {
    if (!this.wallet) {
      throw new Error('Wallet não inicializado.');
    }
    return this.wallet.address;
  }

  /**
   * Obtém o saldo do wallet
   */
  async getBalance(address = null) {
    const targetAddress = address || this.getAddress();
    const balance = await this.provider.getBalance(targetAddress);
    return ethers.formatEther(balance);
  }

  /**
   * Obtém informações da rede
   */
  async getNetworkInfo() {
    const network = await this.provider.getNetwork();
    const blockNumber = await this.provider.getBlockNumber();
    
    return {
      name: network.name,
      chainId: Number(network.chainId),
      blockNumber
    };
  }
}

// Instância singleton
export const providerManager = new ProviderManager();
