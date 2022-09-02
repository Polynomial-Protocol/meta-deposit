// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "./interfaces/IERC20.sol";
import {IPolynomialVault} from "./interfaces/IPolynomialVault.sol";

interface IRocketFactory {
    function owner() external view returns (address);
}

contract Rocket {
    bytes32 public immutable salt;
    address public immutable owner;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(bytes32 _salt) {
        salt = _salt;
        owner = IRocketFactory(msg.sender).owner();
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
    ) external {
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

    function rescue(
        address token,
        address recipient,
        uint256 amount
    ) external requiresAuth {
        IERC20(token).transfer(recipient, amount);
    }
}
