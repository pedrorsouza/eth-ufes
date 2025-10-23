import { providerManager } from '../src/utils/provider.js';
import { CounterContract } from '../src/contracts/CounterContract.js';
import { config } from '../src/config/index.js';

/**
 * Exemplo básico de uso do sistema
 */
async function basicExample() {
  try {
    console.log('=== Exemplo Básico de Uso ===\n');
    
    // 1. Inicializa o provider
    console.log('1. Inicializando provider...');
    await providerManager.initialize();
    
    // 2. Obtém informações da rede
    console.log('\n2. Informações da rede:');
    const networkInfo = await providerManager.getNetworkInfo();
    console.log(`Rede: ${networkInfo.name}`);
    console.log(`Chain ID: ${networkInfo.chainId}`);
    console.log(`Último bloco: ${networkInfo.blockNumber}`);
    
    // 3. Verifica saldo (se wallet estiver configurado)
    try {
      const balance = await providerManager.getBalance();
      console.log(`\n3. Saldo do wallet: ${balance} ETH`);
    } catch (error) {
      console.log('\n3. Wallet não configurado - apenas operações de leitura disponíveis');
    }
    
    // 4. Interage com o contrato Counter (se endereço estiver configurado)
    if (config.contracts.counter) {
      console.log('\n4. Interagindo com contrato Counter...');
      const counter = new CounterContract(config.contracts.counter);
      await counter.initialize();
      
      // Demonstra as funcionalidades
      await counter.demonstrate();
    } else {
      console.log('\n4. Endereço do contrato Counter não configurado');
      console.log('Configure COUNTER_CONTRACT_ADDRESS no arquivo .env');
    }
    
  } catch (error) {
    console.error('Erro no exemplo básico:', error);
  }
}

// Executa o exemplo se este arquivo for executado diretamente
if (import.meta.url === `file://${process.argv[1]}`) {
  basicExample();
}

export { basicExample };
