// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICurvePool {
    function exchange(
        int128 from,
        int128 to,
        uint256 amount,
        uint256 minReceived
    ) external;
}
