#!/bin/bash

# Script para testar se os scripts estão usando PRIVATE_KEY corretamente

echo "🔑 Testando scripts de deploy com PRIVATE_KEY..."

# Verificar se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo "❌ Arquivo .env não encontrado"
    echo "📝 Copie o arquivo env.example para .env e configure suas variáveis"
    exit 1
fi

# Verificar se PRIVATE_KEY está configurada
if ! grep -q "PRIVATE_KEY=" .env || grep -q "PRIVATE_KEY=your_private_key_here" .env; then
    echo "❌ PRIVATE_KEY não configurada no arquivo .env"
    echo "📝 Configure sua chave privada no arquivo .env"
    exit 1
fi

echo "✅ PRIVATE_KEY configurada no .env"

# Verificar se os scripts estão usando vm.envUint("PRIVATE_KEY")
echo "🔍 Verificando scripts de deploy..."

scripts=(
    "script/Counter.s.sol"
    "script/ClassVote.s.sol"
    "script/Escrow.s.sol"
    "script/TimeLockVault.s.sol"
    "script/SafePiggy.s.sol"
    "script/DeployAll.s.sol"
)

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if grep -q 'vm.envUint("PRIVATE_KEY")' "$script"; then
            echo "✅ $script está usando vm.envUint(\"PRIVATE_KEY\")"
        else
            echo "❌ $script NÃO está usando vm.envUint(\"PRIVATE_KEY\")"
            exit 1
        fi
    else
        echo "❌ $script não encontrado"
        exit 1
    fi
done

# Verificar se os scripts estão usando vm.startBroadcast(deployerKey)
echo "🔍 Verificando uso de vm.startBroadcast(deployerKey)..."

for script in "${scripts[@]}"; do
    if grep -q 'vm.startBroadcast(deployerKey)' "$script"; then
        echo "✅ $script está usando vm.startBroadcast(deployerKey)"
    else
        echo "❌ $script NÃO está usando vm.startBroadcast(deployerKey)"
        exit 1
    fi
done

# Verificar se os scripts têm require para PRIVATE_KEY
echo "🔍 Verificando validação de PRIVATE_KEY..."

for script in "${scripts[@]}"; do
    if grep -q 'require(deployerKey != 0, "Missing PRIVATE_KEY")' "$script"; then
        echo "✅ $script tem validação de PRIVATE_KEY"
    else
        echo "❌ $script NÃO tem validação de PRIVATE_KEY"
        exit 1
    fi
done

echo ""
echo "🎉 Todos os scripts estão configurados corretamente!"
echo ""
echo "📚 Como usar:"
echo "1. Configure sua PRIVATE_KEY no arquivo .env"
echo "2. Configure sua RPC_URL no arquivo .env"
echo "3. Execute: make deploy-all network=sepolia"
echo ""
echo "🔑 A PRIVATE_KEY será lida automaticamente pelos scripts!"
echo "✅ Não é mais necessário usar --private-key nos comandos!"
