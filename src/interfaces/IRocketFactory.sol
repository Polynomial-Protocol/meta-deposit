// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRocketFactory {
    function owner() external view returns (address);

    function hTokens(address) external view returns (address);

    function hSwaps(address) external view returns (address);
}
