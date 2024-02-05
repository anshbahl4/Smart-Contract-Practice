// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 messaging smart contract

Users will be able to register themselves by providing a username.
Users can send messages to other registered users.
Each message will include the sender's username, recipient's username, and the message content.
Users can retrieve their received messages.
 */

contract MessagingSmartContract {

    string[] public usernames;

    struct Message {
        string sender;
        string recipient;
        string content;
    }

    Message[] public messages;

    event StoreUsername(string indexed username, address indexed userAddress);
    event SendMessage(string indexed sender, string indexed recipient, string content);

    function enterUsername(string memory _username) public {
        require(bytes(_username).length > 0, "Username not entered correctly");
        require(!usernameExists(_username), "Username already exists");

        usernames.push(_username);
        emit StoreUsername(_username, msg.sender);
    }

    function usernameExists(string memory _username) public view returns(bool) {
        for (uint256 i = 0; i < usernames.length; i++) {
            if (keccak256(bytes(usernames[i])) == keccak256(bytes(_username))) {
                return true;
            }
        }
        return false;
    }

    function sendMessage(string memory _recipient, string memory _content) public {
        require(bytes(_recipient).length > 0, "Recipient not entered correctly");
        require(usernameExists(_recipient), "Recipient does not exist");

        Message memory newMessage = Message({
            sender: usernames[getUserIndex(msg.sender)],
            recipient: _recipient,
            content: _content
        });

        messages.push(newMessage);
        emit SendMessage(newMessage.sender, newMessage.recipient, newMessage.content);
    }

    function getUserIndex(address userAddress) internal view returns (uint256) {
        for (uint256 i = 0; i < usernames.length; i++) {
            if (msg.sender == userAddress) {
                return i;
            }
        }
        revert("User not found");
    }

    function getMessages() public view returns (Message[] memory) {
        uint256 userIndex = getUserIndex(msg.sender);
        uint256 receivedMessageCount = 0;

        // number of received messages
        for (uint256 i = 0; i < messages.length; i++) {
            if (keccak256(bytes(messages[i].recipient)) == keccak256(bytes(usernames[userIndex]))) {
                receivedMessageCount++;
            }
        }

        // Array to store received messages
        Message[] memory receivedMessages = new Message[](receivedMessageCount);
        uint256 currentIndex = 0;

        // increase array size with received messages
        for (uint256 i = 0; i < messages.length; i++) {
            if (keccak256(bytes(messages[i].recipient)) == keccak256(bytes(usernames[userIndex]))) {
                receivedMessages[currentIndex] = messages[i];
                currentIndex++;
            }
        }

        return receivedMessages;
    }
}
