// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    address[] public players;
    uint256 public ticketPrice;
    uint256 public maxTickets;

    constructor(uint256 _ticketPrice, uint256 _maxTickets) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        maxTickets = _maxTickets;
    }

    // Function for users to buy a lottery ticket
    function buyTicket() external payable {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(players.length < maxTickets, "All tickets are sold out");

        players.push(msg.sender);
    }

    // Function to pick a random winner (owner only)
    function pickWinner() external onlyOwner {
        require(players.length == maxTickets, "Not enough players to pick a winner");

        // Using block.timestamp and block.prevrandao for randomness
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players))) % players.length;
        address winner = players[randomIndex];

        // Transfer the entire balance to the winner
        (bool success, ) = payable(winner).call{value: address(this).balance}("");
        require(success, "Transfer to winner failed");

        // Reset the lottery for the next round
        delete players;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to get the current pool balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to check the number of players
    function getPlayers() external view returns (address[] memory) {
        return players;
    }
}