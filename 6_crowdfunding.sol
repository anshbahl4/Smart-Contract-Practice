// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 * Crowdfunding Smart Contract

*Create a new fundraising campaign.
*Contribute funds to a campaign.
*Withdraw funds if the campaign reaches its funding goal before the deadline.
*Refund contributors if the campaign deadline passes, and the funding goal is not reached
 */

contract Crowdfunding {
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool isFundingGoalReached;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCounter;

    event CampaignCreated(uint256 indexed campaignId, address indexed creator, uint256 goal, uint256 deadline);
    event ContributionReceived(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event FundsWithdrawn(uint256 indexed campaignId, address indexed creator, uint256 amount);
    event RefundSent(uint256 indexed campaignId, address indexed contributor, uint256 amount);

    function createCampaign(uint256 _goal, uint256 _durationInDays) external {
        require(_goal > 0, "Goal amount must be greater than zero");
        uint256 deadline = block.timestamp + (_durationInDays * 1 days);

        campaigns[campaignCounter] = Campaign({
            creator: msg.sender,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            isFundingGoalReached: false
        });

        emit CampaignCreated(campaignCounter, msg.sender, _goal, deadline);
        campaignCounter++;
    }

    function contribute(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(!campaign.isFundingGoalReached, "Funding goal already reached");

        campaign.amountRaised += msg.value;
        emit ContributionReceived(_campaignId, msg.sender, msg.value);

        if (campaign.amountRaised >= campaign.goal) {
            campaign.isFundingGoalReached = true;
            emit FundsWithdrawn(_campaignId, campaign.creator, campaign.amountRaised);
        }
    }

    function withdrawFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Only the campaign creator can withdraw funds");
        require(campaign.isFundingGoalReached, "Funding goal not reached");
        
        uint256 amountToWithdraw = campaign.amountRaised;
        campaign.amountRaised = 0;

        payable(campaign.creator).transfer(amountToWithdraw);
        emit FundsWithdrawn(_campaignId, campaign.creator, amountToWithdraw);
    }

    function refundContributors(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign deadline not reached");
        require(!campaign.isFundingGoalReached, "Funding goal reached, no refunds needed");

        uint256 amountToRefund = campaign.amountRaised;
        campaign.amountRaised = 0;

        payable(msg.sender).transfer(amountToRefund);
        emit RefundSent(_campaignId, msg.sender, amountToRefund);
    }
}
