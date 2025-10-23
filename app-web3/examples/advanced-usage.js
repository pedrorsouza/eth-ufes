import { providerManager } from '../src/utils/provider.js';
import { CounterContract } from '../src/contracts/CounterContract.js';
import { config } from '../src/config/index.js';

/**
 * Exemplo avançado com eventos e múltiplas operações
 */
async function advancedExample() {
  try {
    console.log('=== Exemplo Avançado de Uso ===\n');
    
    // Inicializa o provider
    await providerManager.initialize();
    
    if (!config.contracts.counter) {
      console.log('Endereço do contrato Counter não configurado');
      return;
    }
    
    const counter = new CounterContract(config.contracts.counter);
    await counter.initialize();
    
    // Configura listener para eventos
    console.log('\n1. Configurando listener para eventos...');
    await counter.onNumberSet((newNumber) => {
      console.log(`🎉 Evento NumberSet recebido: ${newNumber}`);
    });
    
    // Simula múltiplas operações
    console.log('\n2. Executando múltiplas operações...');
    
    const operations = [
      () => counter.setNumber(100),
      () => counter.increment(),
      () => counter.increment(),
      () => counter.setNumber(0),
      () => counter.increment()
    ];
    
    for (let i = 0; i < operations.length; i++) {
      console.log(`\nOperação ${i + 1}:`);
      try {
        await operations[i]();
        
        // Aguarda um pouco entre operações
        await new Promise(resolve => setTimeout(resolve, 2000));
        
        // Lê o estado atual
        const currentNumber = await counter.getNumber();
        console.log(`Estado atual: ${currentNumber}`);
        
      } catch (error) {
        console.error(`Erro na operação ${i + 1}:`, error.message);
      }
    }
    
    // Para de escutar eventos
    console.log('\n3. Parando de escutar eventos...');
    await counter.stopListeningNumberSet();
    
    console.log('\n=== Exemplo avançado concluído ===');
    
  } catch (error) {
    console.error('Erro no exemplo avançado:', error);
  }
}

/**
 * Exemplo de monitoramento de transações
 */
async function transactionMonitoringExample() {
  try {
    console.log('\n=== Monitoramento de Transações ===\n');
    
    await providerManager.initialize();
    
    if (!config.contracts.counter) {
      console.log('Endereço do contrato Counter não configurado');
      return;
    }
    
    const counter = new CounterContract(config.contracts.counter);
    await counter.initialize();
    
    // Monitora transações pendentes
    console.log('Monitorando transações...');
    
    const provider = providerManager.getProvider();
    
    // Listener para novos blocos
    provider.on('block', async (blockNumber) => {
      console.log(`Novo bloco: ${blockNumber}`);
    });
    
    // Executa uma transação e monitora
    console.log('Enviando transação...');
    const result = await counter.setNumber(999);
    
    console.log(`Transação enviada: ${result.transaction.hash}`);
    console.log(`Gas usado: ${result.receipt.gasUsed}`);
    console.log(`Status: ${result.receipt.status === 1 ? 'Sucesso' : 'Falha'}`);
    
  } catch (error) {
    console.error('Erro no monitoramento:', error);
  }
}

// Executa os exemplos se este arquivo for executado diretamente
if (import.meta.url === `file://${process.argv[1]}`) {
  advancedExample()
    .then(() => transactionMonitoringExample())
    .catch(console.error);
}

export { advancedExample, transactionMonitoringExample };
