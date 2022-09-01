// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPolynomialVault {
    struct QueuedDeposit {
        uint256 id;
        address user;
        uint256 depositedAmount;
        uint256 mintedTokens;
        uint256 requestedTime;
    }

    function depositQueue(uint256 index) external view returns (QueuedDeposit memory);

    function nextQueuedDepositId() external view returns (uint256);

    function initiateDeposit(address user, uint256 amount) external;
}
