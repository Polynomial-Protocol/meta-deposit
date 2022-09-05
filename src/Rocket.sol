// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IRocketFactory} from "./interfaces/IRocketFactory.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {IPolynomialVault} from "./interfaces/IPolynomialVault.sol";
import {IHopSwap} from "./interfaces/IHopSwap.sol";

contract Rocket {
    bytes32 public immutable salt;
    address public immutable owner;
    IRocketFactory public immutable factory;

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IWETH public constant WETH =
        IWETH(0x4200000000000000000000000000000000000006);

    constructor(bytes32 _salt) {
        salt = _salt;
        factory = IRocketFactory(msg.sender);
        owner = factory.owner();
    }

    modifier requiresAuth() {
        require(owner == msg.sender, "UNAUTHORIZED");
        _;
    }

    function launch(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) public {
        require(
            salt ==
                keccak256(
                    abi.encode(
                        incomingToken,
                        depositToken,
                        vault,
                        user,
                        amount,
                        swapTarget,
                        swapData
                    )
                ),
            "SALT_MISMATCH"
        );

        if (incomingToken != depositToken) {
            require(
                swapTarget != address(0x0) && swapData.length > 0,
                "INVALID_REQUEST"
            );

            uint256 msgValue;

            if (incomingToken == ETH) {
                msgValue = address(this).balance;
                require(msgValue == amount, "INVALID_BALANCE");
            } else {
                IERC20(incomingToken).approve(swapTarget, amount);
            }

            (bool success, ) = swapTarget.call{value: msgValue}(swapData);
            require(success);
        }

        uint256 depositAmount = IERC20(depositToken).balanceOf(address(this));
        IERC20(depositToken).approve(vault, depositAmount);
        IPolynomialVault(vault).initiateDeposit(user, depositAmount);
    }

    function swapAndLaunch(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) external {
        IERC20 hToken = IERC20(factory.hTokens(incomingToken));
        IHopSwap hSwap = IHopSwap(factory.hSwaps(incomingToken));

        uint256 balance = hToken.balanceOf(address(this));
        hToken.approve(address(hSwap), balance);
        hSwap.swap(1, 0, balance, 0, block.timestamp + 600);

        if (incomingToken == ETH) {
            uint256 wethReceived = WETH.balanceOf(address(this));
            WETH.withdraw(wethReceived);
        }

        launch(
            incomingToken,
            depositToken,
            vault,
            user,
            amount,
            swapTarget,
            swapData
        );
    }

    function rescue(
        address token,
        address recipient,
        uint256 amount
    ) external requiresAuth {
        IERC20(token).transfer(recipient, amount);
    }

    receive() external payable {}
}
