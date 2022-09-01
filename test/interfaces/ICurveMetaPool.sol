// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICurveMetaPool {
    function exchange_underlying(
        int128 from,
        int128 to,
        uint256 amount,
        uint256 minReceived
    ) external;
}
