// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ClassVote {
    // ---------- Admin (controle de fase) ----------
    address public immutable admin;

    // ---------- Propostas ----------
    struct Proposal {
        string name;
        uint256 votes;
    }

    Proposal[] public proposals;

    // ---------- Um voto por endereço ----------
    mapping(address => bool) public voted;

    // ---------- Fases ----------
    enum Phase {
        Setup,
        Voting,
        Ended
    }

    Phase public phase;

    // ---------- Eventos ----------
    event Opened();
    event Voted(address indexed voter, uint256 indexed proposal);
    event Closed();

    // ---------- Erros ----------
    error OnlyAdmin();
    error PhaseError();
    error AlreadyVoted();
    error IndexOutOfBounds();
    // ---------- Modifiers ----------

    modifier onlyAdmin() {
        if (msg.sender != admin) revert OnlyAdmin();
        _;
    }

    modifier inPhase(Phase p) {
        if (phase != p) revert PhaseError();
        _;
    }

    // ---------- Constructor ----------
    // Recebe os nomes das propostas e começa em Setup.
    constructor(string[] memory names) {
        admin = msg.sender;
        for (uint256 i = 0; i < names.length; i++) {
            proposals.push(Proposal({name: names[i], votes: 0}));
        }
        phase = Phase.Setup;
    }

    // ---------- Abrir votação ----------
    function openVoting() external onlyAdmin inPhase(Phase.Setup) {
        phase = Phase.Voting;
        emit Opened();
    }

    // ---------- Votar em uma proposta ----------
    function vote(uint256 index) external inPhase(Phase.Voting) {
        if (voted[msg.sender]) revert AlreadyVoted();
        if (index >= proposals.length) revert IndexOutOfBounds();

        voted[msg.sender] = true; // registra primeiro (Effects)
        proposals[index].votes += 1; // depois altera votos
        emit Voted(msg.sender, index);
    }

    // ---------- Encerrar votação ----------
    function closeVoting() external onlyAdmin inPhase(Phase.Voting) {
        phase = Phase.Ended;
        emit Closed();
    }

    // ---------- Ver vencedor ----------
    function winner() external view inPhase(Phase.Ended) returns (uint256 idx) {
        uint256 max = 0;
        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].votes > max) {
                max = proposals[i].votes;
                idx = i;
            }
        }
    }

    // ---------- Ajudas de leitura ----------
    function proposalsCount() external view returns (uint256) {
        return proposals.length;
    }
}
