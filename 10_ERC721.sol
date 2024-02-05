// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * ERC721 Smart Contract
 */

contract ERC721 {
    string public tokenName;
    string public symbol;
    uint256 public totalSupply;

    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256[]) public tokensOwnedBy;

    address public owner;

    constructor(string memory _tokenName, string memory _symbol, uint256 _totalSupply) {
        tokenName = _tokenName;
        symbol = _symbol;
        totalSupply = _totalSupply;
        owner = msg.sender; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function mint(address _to, uint256 _tokenId) public onlyOwner {
        require(_tokenId > 0 && _tokenId <= totalSupply, "Invalid token ID");
        require(tokenOwners[_tokenId] == address(0), "Token already minted");

        tokenOwners[_tokenId] = _to;
        tokensOwnedBy[_to].push(_tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public {
        require(msg.sender == tokenOwners[_tokenId], "You are not the owner of this token");
        require(_to != address(0), "Invalid recipient address");

        tokenOwners[_tokenId] = _to;
    }

    function listOfTokenIds(address _person) public view returns (uint256[] memory) {
        return tokensOwnedBy[_person];
    }
}
