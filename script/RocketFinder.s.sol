// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {RocketFactory} from "../src/RocketFactory.sol";

contract RocketFinder is Script {
    uint256 optimismFork;
    RocketFactory rocketFactory;

    function setUp() public {
        optimismFork = vm.createSelectFork(vm.rpcUrl("optimism"), 27000000);

        rocketFactory = RocketFactory(
            0x1d7CDcb7E6a665C82131Db0fE776E1dfdb5A8b29
        );
    }

    function run() public {
        address target = 0x9ae114adA8D052987C3436629A8458c542A86B6d;

        for (uint256 i = 61.8e6; i < 61.9e6; i++) {
            address newTarget = rocketFactory.getAddressFor(
                0x7F5c764cBc14f9669B88837ca1490cCa17c31607,
                0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9,
                0xb28Df1b71a5b3a638eCeDf484E0545465a45d2Ec,
                0x572eFEfaCD35F8aCf0bA8d0a89332e8B3A52c6ac,
                i,
                0x061b87122Ed14b9526A813209C8a59a633257bAb
            );

            if (target == newTarget) {
                console2.log(i);
                break;
            }
        }

        console2.log(target);
    }
}
