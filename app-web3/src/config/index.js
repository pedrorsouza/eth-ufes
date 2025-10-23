import dotenv from 'dotenv';

// Carrega variáveis de ambiente
dotenv.config();

export const config = {
  // Configurações da rede
  rpcUrl: process.env.RPC_URL || 'http://localhost:8545',
  privateKey: process.env.PRIVATE_KEY || '',
  chainId: parseInt(process.env.CHAIN_ID || '1'),
  
  // Configurações de gas
  gasLimit: parseInt(process.env.GAS_LIMIT || '300000'),
  gasPrice: process.env.GAS_PRICE || '20000000000',
  
  // Endereços dos contratos
  contracts: {
    counter: process.env.COUNTER_CONTRACT_ADDRESS || '',
  },
  
  // Configurações de rede por ambiente
  networks: {
    mainnet: {
      rpcUrl: 'https://mainnet.infura.io/v3/YOUR_PROJECT_ID',
      chainId: 1,
      name: 'Ethereum Mainnet'
    },
    sepolia: {
      rpcUrl: 'https://sepolia.infura.io/v3/YOUR_PROJECT_ID',
      chainId: 11155111,
      name: 'Sepolia Testnet'
    },
    localhost: {
      rpcUrl: 'http://localhost:8545',
      chainId: 1337,
      name: 'Local Development'
    }
  }
};

export default config;
