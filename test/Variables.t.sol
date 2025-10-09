// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Variables.sol";

contract VariablesTest is Test {
    Variables public variables;

    function setUp() public {
        console.log("=== CONFIGURACAO INICIAL ===");
        console.log("Criando nova instancia do contrato Variables...");
        variables = new Variables();
        console.log("Contrato Variables criado com sucesso!");
        console.log("Valores iniciais das variaveis:");
        console.log("- number (public):", variables.number());
        console.log("=====================================\n");
    }

    function testPublicVariableDirectAccess() public {
        console.log("=== TESTE: VARIAVEL PUBLIC ===");
        console.log("Objetivo: Demonstrar que variaveis PUBLIC podem ser lidas diretamente");
        console.log("Explicacao: Variaveis public tem getter automatico gerado pelo Solidity");
        
        // Testa que variável public pode ser lida diretamente
        console.log("\n1. Lendo valor inicial da variavel public...");
        uint256 initialValue = variables.number();
        console.log("   Valor inicial:", initialValue);
        assertEq(initialValue, 0, "Initial public number should be 0");
        console.log("   OK - Valor inicial correto (0)");

        // Modifica a variável public
        console.log("\n2. Modificando variavel public com setNumber(42)...");
        variables.setNumber(42);
        console.log("   Funcao setNumber() executada com sucesso");
        
        // Lê diretamente a variável public (getter automático)
        console.log("\n3. Lendo variavel public diretamente (getter automatico)...");
        uint256 newValue = variables.number();
        console.log("   Novo valor:", newValue);
        assertEq(newValue, 42, "Public number should be 42");
        console.log("   OK - Getter automatico funcionou perfeitamente!");
        
        console.log("\nCONCLUSAO: Variaveis PUBLIC sao acessiveis externamente");
        console.log("   - Tem getter automatico: variables.number()");
        console.log("   - Podem ser lidas de qualquer lugar");
        console.log("=====================================\n");
    }

    function testInternalVariableCannotBeAccessedDirectly() public {
        console.log("=== TESTE: VARIAVEL INTERNAL ===");
        console.log("Objetivo: Demonstrar que variaveis INTERNAL NAO podem ser lidas externamente");
        console.log("Explicacao: Variaveis internal sao acessiveis apenas dentro do contrato e contratos derivados");
        
        console.log("\n1. Tentando acessar variavel internal diretamente...");

        // A única forma de acessar é através do setter
        console.log("\n2. Usando setter para modificar variavel internal...");
        console.log("   Executando: variables.setNumber2(100)");
        variables.setNumber2(100);
        //uint256 newValue = variables.number2();
        console.log("   OK - Funcao setNumber2() executada com sucesso");
        
        console.log("\n3. usando getter para ler variavel internal...");
        uint256 newValue2 = variables.getNumber2();
        console.log("   Valor retornado:", newValue2);
        assertEq(newValue2, 100, "Internal number should be 100");
        
        console.log("\nCONCLUSAO: Variaveis INTERNAL tem restricoes de acesso");
    }

    function testPrivateVariableCannotBeAccessedDirectly() public {
        console.log("=== TESTE: VARIAVEL PRIVATE ===");
        console.log("Objetivo: Demonstrar que variaveis PRIVATE NAO podem ser lidas externamente");
        console.log("Explicacao: Variaveis private sao acessiveis APENAS dentro do proprio contrato");
        
        console.log("\n1. Tentando acessar variavel private diretamente...");
        
        // A única forma de acessar é através do setter
        console.log("\n2. Usando setter para modificar variavel private...");
        console.log("   Executando: variables.setNumber3(200)");
        variables.setNumber3(200);
        //uint256 newValue = variables.number3();
        console.log("   OK - Funcao setNumber3() executada com sucesso");
        
        console.log("\n3. usando getter para ler variavel private...");
        uint256 newValue3 = variables.getNumber3();
        console.log("   Valor retornado:", newValue3);
        assertEq(newValue3, 200, "Private number should be 200");
        
    }

}