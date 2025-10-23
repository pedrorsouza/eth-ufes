import { providerManager } from './src/utils/provider.js';
import { CounterContract } from './src/contracts/CounterContract.js';
import { config } from './src/config/index.js';

/**
 * Arquivo principal do projeto ETH-UFES Web3
 * Demonstra as principais funcionalidades do sistema
 */
async function main() {
  console.log('🚀 ETH-UFES Web3 - Sistema Modular para Contratos Ethereum\n');
  
  try {
    // Inicializa o provider
    console.log('📡 Inicializando conexão com a blockchain...');
    await providerManager.initialize();
    
    // Mostra informações da rede
    const networkInfo = await providerManager.getNetworkInfo();
    console.log(`✅ Conectado à rede: ${networkInfo.name} (Chain ID: ${networkInfo.chainId})`);
    console.log(`📦 Último bloco: ${networkInfo.blockNumber}`);
    
    // Mostra saldo se wallet estiver configurado
    try {
      const balance = await providerManager.getBalance();
      console.log(`💰 Saldo: ${balance} ETH`);
    } catch (error) {
      console.log('ℹ️  Wallet não configurado - apenas operações de leitura disponíveis');
    }
    
    // Interage com o contrato Counter se configurado
    if (config.contracts.counter) {
      console.log('\n🔗 Interagindo com contrato Counter...');
      const counter = new CounterContract(config.contracts.counter);
      await counter.initialize();
      
      // Demonstra funcionalidades
      await counter.demonstrate();
    } else {
      console.log('\n⚠️  Endereço do contrato Counter não configurado');
      console.log('📝 Configure COUNTER_CONTRACT_ADDRESS no arquivo .env');
      console.log('📖 Consulte o README.md para instruções detalhadas');
    }
    
    console.log('\n🎉 Sistema inicializado com sucesso!');
    console.log('📚 Execute os exemplos em examples/ para mais funcionalidades');
    
  } catch (error) {
    console.error('❌ Erro ao inicializar sistema:', error.message);
    console.log('\n🔧 Verifique suas configurações:');
    console.log('   - RPC_URL está correto?');
    console.log('   - PRIVATE_KEY está configurado?');
    console.log('   - Arquivo .env existe?');
  }
}

// Executa o main se este arquivo for executado diretamente
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { main };
