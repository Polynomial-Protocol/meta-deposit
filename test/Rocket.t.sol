// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Test } from "forge-std/Test.sol";
import { Rocket } from "../src/Rocket.sol";
import { RocketFactory } from "../src/RocketFactory.sol";
import { IERC20 } from "../src/interfaces/IERC20.sol";

contract RocketTest is Test {
    uint256 optimismFork;

    address SUSD_HOLDER = 0x5Db73886c4730dBF3C562ebf8044E19E8C93843e;
    address SUSD = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;
    address SETH_PUT_SELLING = 0xb28Df1b71a5b3a638eCeDf484E0545465a45d2Ec;

    address user = 0xf601c32B01ACbA505b139330029694Bede296951;
    uint256 amount = 1e21; // 1000 sUSD

    function setUp() public {
        optimismFork = vm.createSelectFork(vm.rpcUrl("optimism"), 21340000);
    }

    function testLaunch() public {
        RocketFactory rocketFactory = new RocketFactory();

        address predictedAddress = rocketFactory.getAddressFor(SUSD, SUSD, SETH_PUT_SELLING, user, amount, address(0x0), "");

        vm.prank(SUSD_HOLDER);
        IERC20(SUSD).transfer(predictedAddress, amount);

        address newRocket = rocketFactory.deploy(SUSD, SUSD, SETH_PUT_SELLING, user, amount, address(0x0), "");

        Rocket(newRocket).launch(SUSD, SUSD, SETH_PUT_SELLING, user, amount, address(0x0), "");
    }
}
