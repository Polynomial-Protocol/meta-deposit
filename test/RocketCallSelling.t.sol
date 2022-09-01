// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {Rocket} from "../src/Rocket.sol";
import {RocketFactory} from "../src/RocketFactory.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IPolynomialVault} from "../src/interfaces/IPolynomialVault.sol";

contract RocketCallSellingTest is Test {
    RocketFactory rocketFactory;
    uint256 optimismFork;

    address SETH_HOLDER = 0x5Db73886c4730dBF3C562ebf8044E19E8C93843e;
    address SETH = 0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49;
    address SETH_CALL_SELLING = 0x2D46292cbB3C601c6e2c74C32df3A4FCe99b59C7;

    address user = 0xf601c32B01ACbA505b139330029694Bede296951;

    function setUp() public {
        optimismFork = vm.createSelectFork(vm.rpcUrl("optimism"), 21510000);
        rocketFactory = new RocketFactory();
    }

    function assertDepositQueue(address depositedUser) internal {
        IPolynomialVault vault = IPolynomialVault(SETH_CALL_SELLING);

        uint256 nextDepositId = vault.nextQueuedDepositId();
        IPolynomialVault.QueuedDeposit memory lastQueued = vault.depositQueue(
            --nextDepositId
        );

        assertEq(lastQueued.user, depositedUser);
        assertGt(lastQueued.depositedAmount, 0);
    }

    function testSimple() public {
        uint256 amount = 1e18; // 1 SETH

        address predictedAddress = rocketFactory.getAddressFor(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        vm.prank(SETH_HOLDER);
        IERC20(SETH).transfer(predictedAddress, amount);

        address newRocket = rocketFactory.deploy(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        Rocket(newRocket).launch(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        assertDepositQueue(user);
    }

    function testSimple(uint256 amount) public {
        vm.assume(amount > 1e16 && amount < 1e21);

        address predictedAddress = rocketFactory.getAddressFor(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        vm.prank(SETH_HOLDER);
        IERC20(SETH).transfer(predictedAddress, amount);

        address newRocket = rocketFactory.deploy(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        Rocket(newRocket).launch(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        assertDepositQueue(user);
    }
}
