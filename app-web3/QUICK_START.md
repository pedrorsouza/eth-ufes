# 🚀 Quick Start - ETH-UFES Web3

## Instalação Rápida

```bash
# 1. Instalar dependências
npm install

# 2. Configurar variáveis
cp env.example .env
# Edite o arquivo .env com suas configurações

# 3. Testar sistema
node examples/demo-offline.js
```

## Configuração Mínima

Crie um arquivo `.env` com:

```env
# Para testnet Sepolia
RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
PRIVATE_KEY=your_private_key_here
COUNTER_CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890
```

## Uso Básico

```bash
# Executar sistema principal
npm start

# Exemplo básico
node examples/basic-usage.js

# Exemplo avançado
node examples/advanced-usage.js
```

## Estrutura Modular

```
src/
├── config/          # Configurações
├── contracts/        # Classes de contratos
├── utils/           # Utilitários
└── abis/            # ABIs dos contratos
```

## Adicionar Novo Contrato

1. **Criar ABI**: `src/abis/MeuContrato.json`
2. **Criar Classe**: `src/contracts/MeuContrato.js`
3. **Usar**: `import { MeuContrato } from './src/contracts/MeuContrato.js'`

## Troubleshooting

- **Erro de conexão**: Verifique RPC_URL
- **Wallet não funciona**: Configure PRIVATE_KEY
- **Contrato não encontrado**: Verifique endereço

## Próximos Passos

1. Configure sua rede Ethereum
2. Deploy seus contratos
3. Teste as interações
4. Adicione novos contratos conforme necessário

---

**Sistema pronto para uso!** 🎉
