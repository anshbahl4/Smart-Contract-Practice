// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

/**
 * Auction Smart Contract

*Auction Creation: Create a new auction by specifying the token being auctioned, the quantity, the starting price, and the duration of the auction.
*Bidding: Allow users to place bids on an ongoing auction. Each bid should include the bid amount and the bidder's address.
*Auction Completion: Automatically determine the highest bidder when the auction duration expires, and allow the token to be transferred to the highest bidder while transferring the bid amount to the auction creator.
*Bid Withdrawal: Allow bidders to withdraw their bids if the auction is still ongoing.
 */

contract Auditing {
    uint256 public totalSupply;
    mapping(address => uint256) public trackBalance;
    mapping(address => mapping(address => uint256)) public allowances;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyOnce() {
        require(totalSupply == 0, "Total supply can only be initialized once");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    struct Auction {
        address token;
        uint256 quantity;
        uint256 startingPrice;
        uint256 duration;
        uint256 startTime;
        uint256 highestBid;
        address highestBidder;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCounter;

    event AuctionCreated(uint256 indexed auctionId, address indexed token, uint256 quantity, uint256 startingPrice, uint256 duration);
    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionCompleted(uint256 indexed auctionId, address indexed winner, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function initializeFixedSupply(uint256 _totalSupply) external onlyOwner onlyOnce {
        totalSupply = _totalSupply;
        trackBalance[owner] = _totalSupply;
    }

    function retrieveBalance() external onlyOwner {
        uint256 balanceToSend = trackBalance[msg.sender];
        require(balanceToSend > 0, "Owner has no balance to retrieve");

        // Transfer balance to the owner
        payable(owner).transfer(balanceToSend);

        // Reset balance to zero after transfer
        trackBalance[msg.sender] = 0;
    }

    function getBalance(address participant) external view returns (uint256) {
        return trackBalance[participant];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(amount <= trackBalance[msg.sender], "Insufficient balance");
        trackBalance[msg.sender] -= amount;
        trackBalance[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(amount <= trackBalance[from], "Insufficient balance");
        require(amount <= allowances[from][msg.sender], "Allowance exceeded");

        trackBalance[from] -= amount;
        trackBalance[to] += amount;
        allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    modifier onlyDuringAuction(uint256 _auctionId) {
        require(
            block.timestamp >= auctions[_auctionId].startTime && 
            block.timestamp <= auctions[_auctionId].startTime + auctions[_auctionId].duration,
            "Auction not active"
        );
        _;
    }

    modifier onlyAfterAuctionEnd(uint256 _auctionId) {
        require(
            block.timestamp > auctions[_auctionId].startTime + auctions[_auctionId].duration,
            "Auction not ended"
        );
        _;
    }

    function createAuction(address _token, uint256 _quantity, uint256 _startingPrice, uint256 _duration) external {
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_startingPrice > 0, "Starting price must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");

        auctions[auctionCounter] = Auction({
            token: _token,
            quantity: _quantity,
            startingPrice: _startingPrice,
            duration: _duration,
            startTime: block.timestamp + 1,  // Add 1 second delay to prevent instant completion
            highestBid: 0,
            highestBidder: address(0)
        });

        emit AuctionCreated(auctionCounter, _token, _quantity, _startingPrice, _duration);
        auctionCounter++;
    }

    function getAuctionDetails(uint256 _auctionId) external view returns (Auction memory) {
        return auctions[_auctionId];
    }

    function placeBid(uint256 _auctionId, uint256 _amount) external onlyDuringAuction(_auctionId) {
        require(_amount > auctions[_auctionId].highestBid, "Bid amount must be higher than the current highest bid");
        require(_amount >= auctions[_auctionId].startingPrice, "Bid amount must be greater than or equal to the starting price");

        if (auctions[_auctionId].highestBidder != address(0)) {
            // Refund the previous highest bidder
            trackBalance[auctions[_auctionId].highestBidder] += auctions[_auctionId].highestBid;
        }

        // Update highest bid and bidder
        auctions[_auctionId].highestBid = _amount;
        auctions[_auctionId].highestBidder = msg.sender;

        // Log the bid
        emit BidPlaced(_auctionId, msg.sender, _amount);
    }

    function completeAuction(uint256 _auctionId) external onlyAfterAuctionEnd(_auctionId) {
        require(auctions[_auctionId].highestBidder != address(0), "No bids placed in the auction");

        // Transfer the token to the highest bidder
        // Note: You should replace the following line with the actual logic to transfer tokens
        // For example, if it's an ERC-20 token, you would call the token's transfer function.
        // tokenContract.transfer(auctions[_auctionId].highestBidder, auctions[_auctionId].quantity);

        // Transfer the bid amount to the auction creator
        trackBalance[msg.sender] += auctions[_auctionId].highestBid;

        // Log the auction completion
        emit AuctionCompleted(_auctionId, auctions[_auctionId].highestBidder, auctions[_auctionId].highestBid);

        // Reset auction details
        delete auctions[_auctionId];
    }
}
