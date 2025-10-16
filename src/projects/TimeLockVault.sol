// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract TimeLockVault {
    // ---------- Configuração didática ----------
    uint256 public constant MIN_LOCK = 1 days; // mínimo para aprender o conceito

    // ---------- Saldos e desbloqueios por usuário ----------
    mapping(address => uint256) public balances;
    mapping(address => uint64) public unlockTime; // uint64 é suficiente p/ timestamp

    // ---------- Eventos ----------
    event Deposited(address indexed user, uint256 amount, uint256 newUnlock);
    event LockExtended(address indexed user, uint256 newUnlock);
    event Withdrawn(address indexed user, uint256 amount);

    // ---------- Erros ----------
    error ZeroAmount();
    error LockTooShort();
    error NotUnlocked();
    error NoBalance();

    // ---------- Depositar com bloqueio ----------
    // lockSeconds: por quanto tempo quer bloquear a partir de agora
    function deposit(uint256 lockSeconds) external payable {
        if (msg.value == 0) revert ZeroAmount();
        if (lockSeconds < MIN_LOCK) revert LockTooShort();
        // Soma saldo
        balances[msg.sender] += msg.value;

        // Calcula novo unlock: máximo entre atual e (agora + lock)
        uint64 newUnlock = uint64(block.timestamp + lockSeconds);
        if (newUnlock > unlockTime[msg.sender]) {
            unlockTime[msg.sender] = newUnlock;
            emit LockExtended(msg.sender, newUnlock);
        }

        emit Deposited(msg.sender, msg.value, unlockTime[msg.sender]);
    }

    // ---------- Sacar quando o tempo passar ----------
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        if (amount == 0) revert NoBalance();
        if (block.timestamp < unlockTime[msg.sender]) revert NotUnlocked();

        // Effects
        balances[msg.sender] = 0;

        // Interaction
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");

        emit Withdrawn(msg.sender, amount);
    }
    // ---------- Ajuda de UX ----------

    function nextUnlockOf(address user) external view returns (uint256) {
        return unlockTime[user];
    }

    // Evita ETH perdido: obriga usar 'deposit'
    receive() external payable {
        revert("use deposit()");
    }

    fallback() external payable {
        revert("invalid call");
    }
}
