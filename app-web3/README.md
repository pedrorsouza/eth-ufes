# ETH-UFES Web3 - Sistema Modular para Contratos Ethereum

Um sistema modular e extensível para interações com contratos inteligentes Ethereum usando ethers.js v6.

## 📋 Índice

- [Instalação](#instalação)
- [Configuração](#configuração)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Uso Básico](#uso-básico)
- [Exemplos Avançados](#exemplos-avançados)
- [Adicionando Novos Contratos](#adicionando-novos-contratos)
- [API Reference](#api-reference)
- [Troubleshooting](#troubleshooting)

## 🚀 Instalação

### Pré-requisitos

- Node.js 18+ 
- npm ou yarn
- Acesso a uma rede Ethereum (mainnet, testnet ou local)

### Passo a Passo

1. **Clone o repositório e navegue até a pasta:**
```bash
cd app-web3
```

2. **Instale as dependências:**
```bash
npm install
```

3. **Configure as variáveis de ambiente:**
```bash
cp env.example .env
```

4. **Edite o arquivo `.env` com suas configurações:**
```env
RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
PRIVATE_KEY=your_private_key_here
COUNTER_CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890
```

## ⚙️ Configuração

### Variáveis de Ambiente

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `RPC_URL` | URL do RPC da rede Ethereum | `https://sepolia.infura.io/v3/...` |
| `PRIVATE_KEY` | Chave privada do wallet (opcional) | `0x1234...` |
| `COUNTER_CONTRACT_ADDRESS` | Endereço do contrato Counter | `0x1234...` |
| `GAS_LIMIT` | Limite de gas para transações | `300000` |
| `CHAIN_ID` | ID da rede blockchain | `11155111` (Sepolia) |

### Redes Suportadas

- **Mainnet**: Ethereum principal
- **Sepolia**: Testnet Ethereum
- **Localhost**: Rede local (Ganache, Hardhat, etc.)

## 📁 Estrutura do Projeto

```
app-web3/
├── src/
│   ├── config/
│   │   └── index.js              # Configurações do sistema
│   ├── contracts/
│   │   ├── BaseContract.js       # Classe base para contratos
│   │   └── CounterContract.js    # Implementação específica
│   ├── utils/
│   │   └── provider.js           # Gerenciamento de conexões
│   └── abis/
│       └── Counter.json          # ABI do contrato Counter
├── examples/
│   ├── basic-usage.js            # Exemplo básico
│   └── advanced-usage.js         # Exemplos avançados
├── index.js                      # Arquivo principal
├── package.json
├── env.example
└── README.md
```

## 🎯 Uso Básico

### 1. Execução Simples

```bash
npm start
```

### 2. Uso Programático

```javascript
import { providerManager } from './src/utils/provider.js';
import { CounterContract } from './src/contracts/CounterContract.js';

async function exemplo() {
  // Inicializa o provider
  await providerManager.initialize();
  
  // Cria instância do contrato
  const counter = new CounterContract('0x...');
  await counter.initialize();
  
  // Lê dados
  const numero = await counter.getNumber();
  console.log('Número atual:', numero);
  
  // Escreve dados (requer wallet configurado)
  await counter.setNumber(42);
}
```

### 3. Exemplos Práticos

```bash
# Exemplo básico
node examples/basic-usage.js

# Exemplo avançado
node examples/advanced-usage.js
```

## 🔧 Exemplos Avançados

### Monitoramento de Eventos

```javascript
import { CounterContract } from './src/contracts/CounterContract.js';

const counter = new CounterContract('0x...');
await counter.initialize();

// Escuta eventos
await counter.onNumberSet((newNumber) => {
  console.log(`Número alterado para: ${newNumber}`);
});

// Para de escutar
await counter.stopListeningNumberSet();
```

### Múltiplas Operações

```javascript
// Executa várias operações sequencialmente
const operations = [
  () => counter.setNumber(100),
  () => counter.increment(),
  () => counter.increment()
];

for (const operation of operations) {
  await operation();
  const currentNumber = await counter.getNumber();
  console.log(`Estado atual: ${currentNumber}`);
}
```

### Monitoramento de Transações

```javascript
// Monitora novos blocos
const provider = providerManager.getProvider();
provider.on('block', (blockNumber) => {
  console.log(`Novo bloco: ${blockNumber}`);
});
```

## ➕ Adicionando Novos Contratos

### 1. Criar o ABI

Crie um arquivo JSON com o ABI do contrato:

```json
// src/abis/MeuContrato.json
[
  {
    "inputs": [...],
    "name": "minhaFuncao",
    "outputs": [...],
    "type": "function"
  }
]
```

### 2. Criar a Classe do Contrato

```javascript
// src/contracts/MeuContrato.js
import { BaseContract } from './BaseContract.js';
import MeuContratoABI from '../abis/MeuContrato.json' assert { type: 'json' };

export class MeuContrato extends BaseContract {
  constructor(contractAddress) {
    super(contractAddress, MeuContratoABI, 'MeuContrato');
  }

  // Métodos específicos do contrato
  async minhaFuncao(parametro) {
    return await this.read('minhaFuncao', parametro);
  }

  async minhaFuncaoEscrita(valor) {
    return await this.write('minhaFuncaoEscrita', valor);
  }
}
```

### 3. Usar o Novo Contrato

```javascript
import { MeuContrato } from './src/contracts/MeuContrato.js';

const meuContrato = new MeuContrato('0x...');
await meuContrato.initialize();
await meuContrato.minhaFuncao('parametro');
```

## 📚 API Reference

### ProviderManager

```javascript
// Inicializar
await providerManager.initialize(rpcUrl, privateKey);

// Obter provider
const provider = providerManager.getProvider();

// Obter signer
const signer = providerManager.getSigner();

// Obter saldo
const balance = await providerManager.getBalance(address);

// Informações da rede
const networkInfo = await providerManager.getNetworkInfo();
```

### BaseContract

```javascript
// Inicializar
await contract.initialize();

// Operações de leitura
const result = await contract.read('functionName', ...args);

// Operações de escrita
const tx = await contract.write('functionName', ...args);

// Eventos
await contract.listenToEvent('EventName', callback);
await contract.stopListening('EventName');
```

### CounterContract

```javascript
// Métodos específicos
await counter.getNumber();
await counter.setNumber(value);
await counter.increment();

// Eventos
await counter.onNumberSet(callback);
await counter.stopListeningNumberSet();
```

## 🔍 Troubleshooting

### Problemas Comuns

1. **Erro de conexão RPC**
   ```
   Solução: Verifique se RPC_URL está correto e acessível
   ```

2. **Wallet não configurado**
   ```
   Solução: Configure PRIVATE_KEY no arquivo .env
   ```

3. **Contrato não encontrado**
   ```
   Solução: Verifique se o endereço do contrato está correto
   ```

4. **Gas insuficiente**
   ```
   Solução: Aumente GAS_LIMIT ou verifique saldo do wallet
   ```

### Logs de Debug

```javascript
// Habilita logs detalhados
console.log('Provider:', providerManager.getProvider());
console.log('Contrato:', counter.getContractInfo());
```

### Verificação de Configuração

```javascript
import { config } from './src/config/index.js';

console.log('Configurações:', {
  rpcUrl: config.rpcUrl,
  hasPrivateKey: !!config.privateKey,
  contractAddress: config.contracts.counter
});
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para detalhes.

## 📞 Suporte

Para dúvidas ou problemas:

- Abra uma issue no GitHub
- Consulte a documentação do ethers.js
- Verifique os exemplos em `examples/`

---

**Desenvolvido para ETH-UFES** 🚀
