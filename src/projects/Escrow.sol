// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SimpleEscrow {
    // ---------- Agreement roles ----------
    address public immutable BUYER; // the payer
    address public immutable SELLER; // the payee
    address public immutable ARBITER; // the referee who can release or refund

    // ---------- Agreed amount ----------
    uint256 public immutable PRICE; // exact price of the service/product

    // ---------- Escrow lifecycle states ----------
    enum State {
        AwaitingDeposit, // escrow created, waiting for buyer to deposit
        Deposited, // funds deposited by buyer
        Released, // arbiter approved: funds made available to the seller
        Refunded, // arbiter rejected: funds made available to the buyer
        Cancelled // buyer cancelled: funds made available to the buyer

    }

    State public state;

    // ---------- Pull payment balances ----------
    // Tracks how much each party can withdraw at any time.
    mapping(address => uint256) public pending;

    // Track timestamp of the last deposit.
    uint256 public timeLimit = 30 days;
    mapping(address => uint256) public timeLastDeposit;

    // ---------- Events for auditability ----------
    event Deposited(address indexed from, uint256 value);
    event Released(address indexed to, uint256 value);
    event Refunded(address indexed to, uint256 value);
    event Withdrawn(address indexed to, uint256 value);
    event Cancelled(address indexed to, uint256 value);
    event StateChanged(State newState);

    // ---------- Custom errors (gas efficient and explicit) ----------
    error NotBuyer();
    error NotArbiter();
    error InvalidState();
    error WrongAmount();
    error NothingToWithdraw();
    //exercise
    error TimeLimitExceeded();

    // ---------- Modifiers (validation reuse) ----------
    modifier onlyBuyer() {
        if (msg.sender != BUYER) revert NotBuyer();
        _;
    }

    modifier onlyArbiter() {
        if (msg.sender != ARBITER) revert NotArbiter();
        _;
    }

    modifier inState(State expected) {
        if (state != expected) revert InvalidState();
        _;
    }

    // ---------- Constructor ----------
    /// @notice Initializes the escrow with roles and the exact price.
    /// @dev Starts in the AwaitingDeposit state.
    /// @param _buyer The account that must deposit the funds.
    /// @param _seller The account that will receive the funds upon release.
    /// @param _arbiter The neutral party responsible for approving release/refund.
    /// @param _price The exact amount (in wei) to be deposited.
    constructor(address _buyer, address _seller, address _arbiter, uint256 _price) {
        BUYER = _buyer;
        SELLER = _seller;
        ARBITER = _arbiter;
        PRICE = _price;
        state = State.AwaitingDeposit;
        emit StateChanged(state);
    }

    // ---------- Buyer deposit ----------
    /// @notice Buyer deposits the exact agreed price into the escrow.
    /// @dev Requires current state AwaitingDeposit and exact amount.
    /// @custom:error WrongAmount if msg.value != price
    function deposit() external payable onlyBuyer inState(State.AwaitingDeposit) {
        if (msg.value != PRICE) revert WrongAmount();
        state = State.Deposited;
        //exercise
        timeLastDeposit[msg.sender] = block.timestamp;
        emit Deposited(msg.sender, msg.value);
        emit StateChanged(state);
    }

    // ---------- Arbiter approval (release to seller via pull payments) ----------
    /// @notice Arbiter approves the delivery; the seller can then withdraw the funds.
    /// @dev Moves the full price to the seller's pending balance using the Pull over Push pattern.
    function approveRelease() external onlyArbiter inState(State.Deposited) {
        if (block.timestamp - timeLastDeposit[BUYER] > timeLimit) revert TimeLimitExceeded();
        state = State.Released;
        pending[SELLER] += PRICE; // Pull over Push: seller withdraws when desired
        emit Released(SELLER, PRICE);
        emit StateChanged(state);
    }

    // ---------- Arbiter refund decision ----------
    /// @notice Arbiter decides to refund; the buyer can then withdraw the funds.
    /// @dev Moves the full price to the buyer's pending balance.
    /// @dev Refund is always possible, regardless of time limit.
    function refundBuyer() external onlyArbiter inState(State.Deposited) {
        state = State.Refunded;
        pending[BUYER] += PRICE;
        emit Refunded(BUYER, PRICE);
        emit StateChanged(state);
    }

    // ---------- Withdraw (pull payments) ----------
    /// @notice Withdraw available funds from your pending balance.
    /// @dev Applies the Checks-Effects-Interactions (CEI) pattern to avoid reentrancy.
    /// @custom:error NothingToWithdraw if the caller has no pending balance.
    function withdraw() external {
        uint256 amount = pending[msg.sender];
        if (amount == 0) revert NothingToWithdraw();

        // Effects
        pending[msg.sender] = 0;

        // Interaction (at the end)
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // ---------- UX helper ----------
    /// @notice Returns the current state as a human-readable string.
    function status() external view returns (string memory) {
        if (state == State.AwaitingDeposit) return "AwaitingDeposit";
        if (state == State.Deposited) return "Deposited";
        if (state == State.Released) return "Released";
        if (state == State.Refunded) return "Refunded";
        return "Cancelled";
    }

    // Prevent receiving stray ETH outside the intended flow
    receive() external payable {
        revert("use deposit()");
    }

    fallback() external payable {
        revert("invalid call");
    }

    // ---------- Exercises ---------- //

    // ---------- Buyer cancellation ----------
    /// @notice Buyer cancels the escrow; the funds are made available to the buyer.
    /// @dev Moves the full price to the buyer's pending balance.
    /// @custom:error NothingToWithdraw if the caller has no pending balance.
    function cancel() external onlyBuyer inState(State.Deposited) {
        uint256 amount = pending[msg.sender] + PRICE;
        if (amount == 0) revert NothingToWithdraw();
        pending[msg.sender] = 0;

        state = State.Cancelled;
        // Interaction (at the end)
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "transfer failed");
        emit Cancelled(msg.sender, amount);
        emit StateChanged(state);
    }
}
