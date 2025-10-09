// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Logger {
    event Log(string tag);

    // 'virtual' para permitir encadeamento via 'super'
    function hook() public virtual {
        emit Log("Logger.hook");
    }
}

contract Greeter2 {
    event Greeted(string who);

    function hook() public virtual {
        emit Greeted("Greeter2.hook");
    }
}

// Ordem em 'is A, B' define a linearizacao.
// 'override(Logger, Greeter2)' resolve o "conflito" de múltiplos pais.
contract Multi is Logger, Greeter2 {
    // Sobrescreve a função com mesma assinatura em ambos os pais
    function hook() public override(Logger, Greeter2) {
        // Chama a próxima implementação na cadeia (linearização C3)
        super.hook(); // dispara Greeter2.hook OU Logger.hook conforme a ordem
        // Ou seja, // 👉 chama primeiro Logger.hook()
        // Pode adicionar lógica própria também:
        emit Log("Multi.hook");
    }
}