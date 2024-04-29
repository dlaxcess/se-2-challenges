// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	mapping(address => uint256) public balances;
	uint256 public constant threshold = 1 ether;

	bool private stakeCompleted;
	uint256 public deadline = block.timestamp + 30 seconds;
	bool private openForWithdraw;

	event Stake(address indexed from, uint256 value);

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	function stake() public payable {
		require(msg.value > 0, "No money sended");
		require(!stakeCompleted, "Stake completed");
		balances[msg.sender] += msg.value;

		console.log("stake accomplished");
		emit Stake(msg.sender, msg.value);
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
	function execute() public {
		require(block.timestamp > deadline, "Deadline not met");

		if (address(this).balance >= threshold) {
			exampleExternalContract.complete{ value: address(this).balance }();
			stakeCompleted = true;
		} else {
			openForWithdraw = true;
		}
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public {
		require(openForWithdraw, "Withdraws are not opened");

		payable(msg.sender).transfer(balances[msg.sender]);
		balances[msg.sender] = 0;
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256) {
		return deadline > block.timestamp ? deadline - block.timestamp : 0;
	}

	// Add the `receive()` special function that receives eth and calls stake()
	function receive() external payable {
		stake();
	}

	fallback() external payable {
		stake();
	}
}
