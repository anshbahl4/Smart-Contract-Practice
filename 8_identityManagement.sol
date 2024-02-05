// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

/**
 * Identity Management Smart Contract by Ansh Bahl

*Register their identity by providing a unique username and other relevant information.
*Retrieve their own identity details.
*Allow other users to verify and vouch for someone's identity.
*Retrieve the identity details of any user, including the number of vouches they have received.
 */

contract IdentityManagement {
    struct Identity {
        string username;
        string name;
        string email;
        uint256 vouchCount;
    }

    mapping(bytes32 => Identity) public identities;
    mapping(address => bytes32) public addressToKey; 

    event NewIdentity(bytes32 indexed key, string username, string name, string email);
    event IdentityUpdated(bytes32 indexed key, string name, string email);

    function newIdentity(string memory _username, string memory _name, string memory _email) public {
        require(bytes(_username).length > 0 && bytes(_name).length > 0 && bytes(_email).length > 0, "Invalid input");
        bytes32 key = keccak256(abi.encodePacked(_username));
        require(bytes(identities[key].username).length == 0, "Username already exists");

        Identity memory newId = Identity({
            username: _username,
            name: _name,
            email: _email,
            vouchCount: 0
        });

        identities[key] = newId;
        addressToKey[msg.sender] = key; 
        emit NewIdentity(key, _username, _name, _email);
    }

    function retrieveInfo() public view returns (string memory, string memory, string memory, uint256) {
        bytes32 key = keccak256(abi.encodePacked(msg.sender));
        return (identities[key].username, identities[key].name, identities[key].email, identities[key].vouchCount);
    }

    function vouch() public returns (uint256) {
        bytes32 key = keccak256(abi.encodePacked(msg.sender));
        require(bytes(identities[key].username).length > 0, "User does not have an identity");
        identities[key].vouchCount++;
        return identities[key].vouchCount;
    }

    function checkVouchCount(address _person) public view returns (uint256) {
        bytes32 key = keccak256(abi.encodePacked(_person));
        require(bytes(identities[key].username).length > 0, "User does not have an identity");
        return identities[key].vouchCount;
    }

    function updateIdentity(string memory _name, string memory _email) public {
        bytes32 key = addressToKey[msg.sender]; 
        require(bytes(identities[key].username).length > 0, "User does not have an identity");
        identities[key].name = _name;
        identities[key].email = _email;
        emit IdentityUpdated(key, _name, _email);
    }
}
