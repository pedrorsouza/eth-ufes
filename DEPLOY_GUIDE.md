# 🚀 Guia Completo de Deploy - ETH-UFES

## 📋 Resumo do Sistema Implementado

### ✅ Scripts de Deploy Criados

1. **Counter.s.sol** - Deploy do contrato Counter
2. **ClassVote.s.sol** - Deploy do sistema de votação
3. **Escrow.s.sol** - Deploy do sistema de escrow
4. **TimeLockVault.s.sol** - Deploy do cofre com tempo de bloqueio
5. **SafePiggy.s.sol** - Deploy do cofre seguro
6. **DeployAll.s.sol** - Deploy de todos os contratos

### ✅ Comandos Makefile Implementados

```bash
# Deploy individual
make deploy-counter network=sepolia
make deploy-class-vote network=sepolia
make deploy-escrow network=sepolia
make deploy-time-lock network=sepolia
make deploy-safe-piggy network=sepolia

# Deploy todos os contratos
make deploy-all network=sepolia
make deploy-all network=polygon
make deploy-all network=amoy

# Deploy local
make deploy-local

# Deploy com verificação
make deploy-verify network=sepolia

# Testes
make test-all
make test-counter
make test-class-vote
make test-escrow
make test-time-lock
make test-safe-piggy
```

### ✅ Configurações de Ambiente

- **env.example** - Arquivo de configuração completo
- **Makefile** - Comandos automatizados para todas as redes
- **README.md** - Documentação completa atualizada

## 🚀 Como Usar

### 1. Configuração Inicial

```bash
# Copiar arquivo de configuração
cp env.example .env

# Editar com suas configurações
nano .env
```

### 2. Deploy em Sepolia (Recomendado para testes)

```bash
# Deploy todos os contratos
make deploy-all network=sepolia

# Deploy individual
make deploy-counter network=sepolia
```

### 3. Deploy em Polygon

```bash
make deploy-all network=polygon
```

### 4. Deploy Local (Desenvolvimento)

```bash
# Terminal 1: Iniciar rede local
make anvil

# Terminal 2: Deploy
make deploy-local
```

## 📊 Redes Suportadas

| Rede | Comando | Chain ID | Status |
|------|---------|----------|--------|
| Ethereum Mainnet | `network=ethereum` | 1 | ✅ |
| Sepolia Testnet | `network=sepolia` | 11155111 | ✅ |
| Polygon Mainnet | `network=polygon` | 137 | ✅ |
| Polygon Amoy | `network=amoy` | 80002 | ✅ |
| Local (Anvil) | `make deploy-local` | 31337 | ✅ |

## 🔧 Configurações Necessárias

### Variáveis Obrigatórias no .env

```env
# Chave privada (sem 0x)
PRIVATE_KEY=your_private_key_here

# RPC URLs
ETHEREUM_HOLESKY_RPC=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
POLYGON_RPC_URL=https://polygon-mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID
AMOY_RPC_URL=https://polygon-amoy.infura.io/v3/YOUR_INFURA_PROJECT_ID

# API Keys para verificação
ETHERSCAN_API_KEY=your_etherscan_api_key
POLYGONSCAN_API_KEY=your_polygonscan_api_key
```

## 🌐 Integração com Projeto Web3

### 1. Deploy dos Contratos

```bash
make deploy-all network=sepolia
```

### 2. Configurar Projeto Web3

```bash
cd app-web3
cp ../env.example .env
# Edite o .env com os endereços dos contratos
```

### 3. Testar Interações

```bash
npm start
node examples/basic-usage.js
```

## 📝 Logs de Deploy

Após o deploy, os endereços são exibidos no console:

```
=== Contract Addresses ===
Counter: 0x1234...
ClassVote: 0x5678...
SimpleEscrow: 0x9abc...
TimeLockVault: 0xdef0...
SafePiggy: 0x1357...
```

## 🔍 Verificação de Contratos

```bash
# Verificar automaticamente
make deploy-verify network=sepolia

# Verificar manualmente
forge verify-contract <ADDRESS> <CONTRACT_PATH> --etherscan-api-key <API_KEY>
```

## 🧪 Testes

```bash
# Testar todos os contratos
make test-all

# Testar contrato específico
make test-counter
make test-class-vote
make test-escrow
make test-time-lock
make test-safe-piggy

# Teste com gas report
make test-gas
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Erro de compilação**: Execute `forge build`
2. **Erro de rede**: Verifique RPC_URL
3. **Erro de gas**: Aumente GAS_LIMIT
4. **Erro de verificação**: Verifique API_KEY

### Comandos de Diagnóstico

```bash
# Verificar informações da rede
make network-info network=sepolia

# Verificar saldo
make check-balance ADDRESS=<YOUR_ADDRESS> network=sepolia

# Verificar nonce
make check-nonce ADDRESS=<YOUR_ADDRESS> network=sepolia
```

## 📚 Próximos Passos

1. **Configure suas variáveis** no arquivo `.env`
2. **Execute o deploy** com `make deploy-all network=sepolia`
3. **Use os endereços** no projeto Web3
4. **Teste as interações** com os contratos

## 🎉 Sistema Completo!

O sistema está **100% funcional** e pronto para uso:

- ✅ Scripts de deploy para todos os contratos
- ✅ Comandos Makefile para todas as redes
- ✅ Configurações de ambiente completas
- ✅ Documentação detalhada
- ✅ Integração com projeto Web3
- ✅ Testes automatizados

**Sistema pronto para deploy em qualquer rede!** 🚀
