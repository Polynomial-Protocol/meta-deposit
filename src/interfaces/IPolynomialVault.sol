// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPolynomialVault {
    function initiateDeposit(address user, uint256 amount) external;
}
