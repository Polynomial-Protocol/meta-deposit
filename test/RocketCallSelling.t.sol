// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {Rocket} from "../src/Rocket.sol";
import {RocketFactory} from "../src/RocketFactory.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IPolynomialVault} from "../src/interfaces/IPolynomialVault.sol";
import {IHopSwap} from "../src/interfaces/IHopSwap.sol";

import {ICurvePool} from "./interfaces/ICurvePool.sol";

contract RocketCallSellingTest is Test {
    RocketFactory rocketFactory;
    uint256 optimismFork;

    address ETH_HOLDER = 0x4200000000000000000000000000000000000006;
    address ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address SETH_HOLDER = 0x5Db73886c4730dBF3C562ebf8044E19E8C93843e;
    address SETH = 0xE405de8F52ba7559f9df3C368500B6E6ae6Cee49;
    address HETH_SWAP = 0xaa30D6bba6285d0585722e2440Ff89E23EF68864;
    address HETH = 0xE38faf9040c7F09958c638bBDB977083722c5156;
    address SETH_CALL_SELLING = 0x2D46292cbB3C601c6e2c74C32df3A4FCe99b59C7;

    address user = 0xf601c32B01ACbA505b139330029694Bede296951;

    ICurvePool constant CURVE_SETH_POOL =
        ICurvePool(0x7Bc5728BC2b59B45a58d9A576E2Ffc5f0505B35E);

    function setUp() public {
        optimismFork = vm.createSelectFork(vm.rpcUrl("optimism"), 21510000);
        rocketFactory = new RocketFactory(address(this));

        rocketFactory.addMappings(ETH, HETH, HETH_SWAP);
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
            address(0x0)
        );

        vm.prank(SETH_HOLDER);
        IERC20(SETH).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0)
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
            address(0x0)
        );

        vm.prank(SETH_HOLDER);
        IERC20(SETH).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            SETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(0x0)
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

    function testCurveEth() public {
        uint256 amount = 1e18; // 1 SETH

        // ETH = index 0, SETH = index 1
        bytes memory swapData = abi.encodeWithSelector(
            ICurvePool.exchange.selector,
            0,
            1,
            amount,
            0
        );

        address predictedAddress = rocketFactory.getAddressFor(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL)
        );

        vm.prank(ETH_HOLDER);
        predictedAddress.call{value: amount}("");

        address payable newRocket = rocketFactory.deploy(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL)
        );

        Rocket(newRocket).launch(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL),
            swapData
        );

        assertDepositQueue(user);
    }

    function testCurveEth(uint256 amount) public {
        vm.assume(amount > 1e16 && amount < 1e21);

        // ETH = index 0, SETH = index 1
        bytes memory swapData = abi.encodeWithSelector(
            ICurvePool.exchange.selector,
            0,
            1,
            amount,
            0
        );

        address predictedAddress = rocketFactory.getAddressFor(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL)
        );

        vm.prank(ETH_HOLDER);
        predictedAddress.call{value: amount}("");

        address payable newRocket = rocketFactory.deploy(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL)
        );

        Rocket(newRocket).launch(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL),
            swapData
        );

        assertDepositQueue(user);
    }

    function testCurveHEth() public {
        uint256 amount = 1e18; // 1 hETH

        address predictedAddress = rocketFactory.getAddressFor(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL)
        );

        vm.prank(HETH_SWAP);
        IERC20(HETH).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL)
        );

        uint256 expectedAmount = IHopSwap(HETH_SWAP).calculateSwap(
            1,
            0,
            amount
        );

        bytes memory swapData = abi.encodeWithSelector(
            ICurvePool.exchange.selector,
            0,
            1,
            expectedAmount,
            0
        );

        Rocket(newRocket).swapAndLaunch(
            ETH,
            SETH,
            SETH_CALL_SELLING,
            user,
            amount,
            address(CURVE_SETH_POOL),
            swapData
        );

        assertDepositQueue(user);
    }
}
