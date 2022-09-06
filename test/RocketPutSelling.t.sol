// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

import {Rocket} from "../src/Rocket.sol";
import {RocketFactory} from "../src/RocketFactory.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IPolynomialVault} from "../src/interfaces/IPolynomialVault.sol";
import {IHopSwap} from "../src/interfaces/IHopSwap.sol";

import {ICurveMetaPool} from "./interfaces/ICurveMetaPool.sol";

contract RocketPutSellingTest is Test {
    RocketFactory rocketFactory;
    uint256 optimismFork;

    address SUSD_HOLDER = 0x5Db73886c4730dBF3C562ebf8044E19E8C93843e;
    address SUSD = 0x8c6f28f2F1A3C87F0f938b96d27520d9751ec8d9;
    address DAI_HOLDER = 0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE;
    address DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address USDC_HOLDER = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address USDC = 0x7F5c764cBc14f9669B88837ca1490cCa17c31607;
    address USDT_HOLDER = 0x6ab707Aca953eDAeFBc4fD23bA73294241490620;
    address USDT = 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58;
    address HUSDC_SWAP = 0x3c0FFAca566fCcfD9Cc95139FEF6CBA143795963;
    address HUSDC = 0x25D8039bB044dC227f741a9e381CA4cEAE2E6aE8;
    address SETH_PUT_SELLING = 0xb28Df1b71a5b3a638eCeDf484E0545465a45d2Ec;

    address user = 0xf601c32B01ACbA505b139330029694Bede296951;

    ICurveMetaPool constant CURVE_SUSD_METAPOOL =
        ICurveMetaPool(0x061b87122Ed14b9526A813209C8a59a633257bAb);

    function setUp() public {
        optimismFork = vm.createSelectFork(vm.rpcUrl("optimism"), 21510000);
        rocketFactory = new RocketFactory(address(this));

        rocketFactory.addMappings(USDC, HUSDC, HUSDC_SWAP);
    }

    function assertDepositQueue(address depositedUser) internal {
        IPolynomialVault vault = IPolynomialVault(SETH_PUT_SELLING);

        uint256 nextDepositId = vault.nextQueuedDepositId();
        IPolynomialVault.QueuedDeposit memory lastQueued = vault.depositQueue(
            --nextDepositId
        );

        assertEq(lastQueued.user, depositedUser);
        assertGt(lastQueued.depositedAmount, 0);
    }

    function testSimple() public {
        uint256 amount = 1e21; // 1000 sUSD
        address predictedAddress = rocketFactory.getAddressFor(
            SUSD,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(0x0)
        );

        vm.prank(SUSD_HOLDER);
        IERC20(SUSD).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            SUSD,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(0x0)
        );

        Rocket(newRocket).launch(
            SUSD,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        assertDepositQueue(user);
    }

    function testSimple(uint256 amount) public {
        vm.assume(amount > 5e19 && amount < 1e24);
        address predictedAddress = rocketFactory.getAddressFor(
            SUSD,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(0x0)
        );

        vm.prank(SUSD_HOLDER);
        IERC20(SUSD).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            SUSD,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(0x0)
        );

        Rocket(newRocket).launch(
            SUSD,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(0x0),
            ""
        );

        assertDepositQueue(user);
    }

    function testCurveDai() public {
        uint256 amount = 1e21; // 1000 DAI
        // DAI = index 1, SUSD = index 0
        bytes memory swapData = abi.encodeWithSelector(
            ICurveMetaPool.exchange_underlying.selector,
            1,
            0,
            amount,
            0
        );

        address predictedAddress = rocketFactory.getAddressFor(
            DAI,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        vm.prank(DAI_HOLDER);
        IERC20(DAI).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            DAI,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        Rocket(newRocket).launch(
            DAI,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL),
            swapData
        );

        assertDepositQueue(user);
    }

    function testCurveUsdc() public {
        uint256 amount = 1e9; // 1000 USDC
        // USDC = index 2, SUSD = index 0
        bytes memory swapData = abi.encodeWithSelector(
            ICurveMetaPool.exchange_underlying.selector,
            2,
            0,
            amount,
            0
        );

        address predictedAddress = rocketFactory.getAddressFor(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        vm.prank(USDC_HOLDER);
        IERC20(USDC).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        Rocket(newRocket).launch(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL),
            swapData
        );

        assertDepositQueue(user);
    }

    function testCurveUsdc(uint256 amount) public {
        vm.assume(amount > 5e7 && amount < 1e12);
        // USDC = index 2, SUSD = index 0
        bytes memory swapData = abi.encodeWithSelector(
            ICurveMetaPool.exchange_underlying.selector,
            2,
            0,
            amount,
            0
        );

        address predictedAddress = rocketFactory.getAddressFor(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        vm.prank(USDC_HOLDER);
        IERC20(USDC).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        Rocket(newRocket).launch(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL),
            swapData
        );

        assertDepositQueue(user);
    }

    function testCurveUsdt() public {
        uint256 amount = 1e9; // 1000 USDT
        // USDT = index 3, SUSD = index 0
        bytes memory swapData = abi.encodeWithSelector(
            ICurveMetaPool.exchange_underlying.selector,
            3,
            0,
            amount,
            0
        );

        address predictedAddress = rocketFactory.getAddressFor(
            USDT,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        vm.prank(USDT_HOLDER);
        IERC20(USDT).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            USDT,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        Rocket(newRocket).launch(
            USDT,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL),
            swapData
        );

        assertDepositQueue(user);
    }

    function testCurveHusdc() public {
        uint256 amount = 1e9; // 1000 hUSDC

        address predictedAddress = rocketFactory.getAddressFor(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        vm.prank(HUSDC_SWAP);
        IERC20(HUSDC).transfer(predictedAddress, amount);

        address payable newRocket = rocketFactory.deploy(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL)
        );

        uint256 expectedAmount = IHopSwap(HUSDC_SWAP).calculateSwap(
            1,
            0,
            amount
        );

        bytes memory swapData = abi.encodeWithSelector(
            ICurveMetaPool.exchange_underlying.selector,
            2,
            0,
            expectedAmount,
            0
        );

        Rocket(newRocket).swapAndLaunch(
            USDC,
            SUSD,
            SETH_PUT_SELLING,
            user,
            amount,
            address(CURVE_SUSD_METAPOOL),
            swapData
        );

        assertDepositQueue(user);
    }
}
