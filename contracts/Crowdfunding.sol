// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Crowdfunding {
    address public projectCreator;
    uint256 public fundingGoal;
    uint256 public totalFunds;
    mapping(address => uint256) public contributions;
    bool public fundingGoalReached = false;
    bool public crowdfundingEnded = false;

    event FundingReceived(address indexed contributor, uint256 amountContributed);
    event FundingGoalReached(uint256 totalFundsRaised);
    event FundsTransferred(address projectCreator, uint256 totalFunds);

    constructor(uint256 _goal) {
        projectCreator = msg.sender;
        fundingGoal = _goal * 1 ether; // Convert goal to wei
    }

    modifier onlyCreator() {
        require(msg.sender == projectCreator, "Only the project creator can perform this action.");
        _;
    }

    modifier goalNotReached() {
        require(!fundingGoalReached, "Funding goal has already been reached.");
        _;
    }

    modifier crowdfundingNotEnded() {
        require(!crowdfundingEnded, "Crowdfunding has ended.");
        _;
    }

    function contribute() public payable crowdfundingNotEnded {
        require(msg.value > 0, "Contribution amount must be greater than 0");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
        emit FundingReceived(msg.sender, msg.value);

        if (totalFunds >= fundingGoal) {
            fundingGoalReached = true;
            emit FundingGoalReached(totalFunds);
        }
    }

    function endCrowdfunding() public onlyCreator goalNotReached {
        crowdfundingEnded = true;

        if (fundingGoalReached) {
            payable(projectCreator).transfer(totalFunds);
            emit FundsTransferred(projectCreator, totalFunds);
        }
    }
}
