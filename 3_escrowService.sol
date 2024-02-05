// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 I created a flexible escrow contract that allows depositing, releasing, and refunding funds based 
 on specified conditions.
 */
contract FlexibleEscrow {
    address public owner;
    uint256 public depositAmount;
    address public depositor;
    address public recipient;
    bool public fundsReleased;
    bool public escrowClosed;
    string public conditions;

    event FundsDeposited(address indexed depositor, uint256 amount, string conditions);
    event ConditionsSet(address indexed owner, address indexed recipient);
    event FundsReleased(address indexed recipient, uint256 amount);
    event FundsRefunded(address indexed depositor, uint256 amount);
    event EscrowClosed(address indexed owner, uint256 remainingFunds);
    event FundsWithdrawn(address indexed owner, uint256 withdrawAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to deposit funds into the escrow
    function depositFunds(string memory _conditions) public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        depositAmount += msg.value;
        depositor = msg.sender;
        conditions = _conditions;
        emit FundsDeposited(msg.sender, msg.value, _conditions);
    }

    // Function to set conditions and recipient by the owner
    function setConditions(address _recipient) public onlyOwner {
        require(_recipient != address(0), "Recipient address cannot be 0");
        recipient = _recipient;
        emit ConditionsSet(msg.sender, _recipient);
    }

    // Function to release funds to the recipient
    function releaseFunds() public onlyOwner {
        require(!fundsReleased && !escrowClosed, "Escrow is closed or funds already released");
        require(conditionsMet(), "Conditions not met for fund release");
        fundsReleased = true;
        escrowClosed = true;
        payable(recipient).transfer(depositAmount);
        emit FundsReleased(recipient, depositAmount);
    }

    // Function to refund funds to the depositor
    function refundFunds() public {
        require(msg.sender == depositor, "Only the depositor can request a refund");
        require(!fundsReleased && !escrowClosed, "Escrow is closed or funds already released");
        fundsReleased = true;
        escrowClosed = true;
        payable(depositor).transfer(depositAmount);
        emit FundsRefunded(depositor, depositAmount);
    }

    // Internal function to check if conditions for fund release are met
    function conditionsMet() internal view returns (bool) {
        return recipient != address(0);
    }

    // Function to close the escrow and withdraw remaining funds by the owner
    function escrowClose() public payable onlyOwner {
        require(!escrowClosed, "Escrow Is closed");
        escrowClosed = true;

        if (address(this).balance > 0) {
            payable(owner).transfer(address(this).balance);
            emit EscrowClosed(owner, address(this).balance);
        }
    }

    // Function to update conditions by the owner
    function updateCondition(string memory _Conditions) public onlyOwner {
        require(!escrowClosed, "Escrow Is closed");
        conditions = _Conditions;
    }

    // Function to withdraw funds by the owner
    function withdrawFunds(uint256 withdrawAmount) public payable onlyOwner {
        if (address(this).balance > withdrawAmount) {
            payable(msg.sender).transfer(withdrawAmount);
            emit FundsWithdrawn(owner, withdrawAmount);
        }
    }

    // Function to update recipient by the owner
    function updateRecipient(address newAddress) public onlyOwner {
        recipient = newAddress;
    }
}
