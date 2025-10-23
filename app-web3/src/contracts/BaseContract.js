import { ethers } from 'ethers';
import { providerManager } from '../utils/provider.js';

/**
 * Classe base para interações com contratos
 */
export class BaseContract {
  constructor(contractAddress, abi, contractName = 'Contract') {
    this.contractAddress = contractAddress;
    this.abi = abi;
    this.contractName = contractName;
    this.contract = null;
    this.contractWithSigner = null;
  }

  /**
   * Inicializa o contrato
   */
  async initialize() {
    try {
      const provider = providerManager.getProvider();
      this.contract = new ethers.Contract(this.contractAddress, this.abi, provider);
      
      // Se há um signer disponível, cria uma instância com signer
      try {
        const signer = providerManager.getSigner();
        this.contractWithSigner = this.contract.connect(signer);
      } catch (error) {
        console.log('Signer não disponível - apenas operações de leitura permitidas');
      }
      
      console.log(`${this.contractName} inicializado no endereço: ${this.contractAddress}`);
      return true;
    } catch (error) {
      console.error(`Erro ao inicializar ${this.contractName}:`, error);
      throw error;
    }
  }

  /**
   * Executa uma função de leitura (view/pure)
   */
  async read(functionName, ...args) {
    try {
      if (!this.contract) {
        throw new Error('Contrato não inicializado');
      }
      
      const result = await this.contract[functionName](...args);
      console.log(`${this.contractName}.${functionName}(${args.join(', ')}) = ${result}`);
      return result;
    } catch (error) {
      console.error(`Erro ao executar ${functionName}:`, error);
      throw error;
    }
  }

  /**
   * Executa uma função de escrita (transação)
   */
  async write(functionName, ...args) {
    try {
      if (!this.contractWithSigner) {
        throw new Error('Signer não disponível para operações de escrita');
      }
      
      console.log(`Enviando transação: ${this.contractName}.${functionName}(${args.join(', ')})`);
      
      const tx = await this.contractWithSigner[functionName](...args);
      console.log(`Transação enviada: ${tx.hash}`);
      
      const receipt = await tx.wait();
      console.log(`Transação confirmada no bloco: ${receipt.blockNumber}`);
      
      return { transaction: tx, receipt };
    } catch (error) {
      console.error(`Erro ao executar ${functionName}:`, error);
      throw error;
    }
  }

  /**
   * Escuta eventos do contrato
   */
  async listenToEvent(eventName, callback) {
    try {
      if (!this.contract) {
        throw new Error('Contrato não inicializado');
      }
      
      this.contract.on(eventName, callback);
      console.log(`Escutando evento: ${eventName}`);
    } catch (error) {
      console.error(`Erro ao escutar evento ${eventName}:`, error);
      throw error;
    }
  }

  /**
   * Para de escutar eventos
   */
  async stopListening(eventName = null) {
    try {
      if (eventName) {
        this.contract.off(eventName);
        console.log(`Parou de escutar evento: ${eventName}`);
      } else {
        this.contract.removeAllListeners();
        console.log('Parou de escutar todos os eventos');
      }
    } catch (error) {
      console.error('Erro ao parar de escutar eventos:', error);
      throw error;
    }
  }

  /**
   * Obtém informações do contrato
   */
  getContractInfo() {
    return {
      name: this.contractName,
      address: this.contractAddress,
      hasSigner: !!this.contractWithSigner
    };
  }
}
