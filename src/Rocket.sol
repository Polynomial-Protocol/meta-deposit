// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "./interfaces/IERC20.sol";
import {IPolynomialVault} from "./interfaces/IPolynomialVault.sol";

contract Rocket {
    bytes32 public immutable salt;

    constructor(bytes32 _salt) {
        salt = _salt;
    }

    function launch(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) external payable {
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

            IERC20(incomingToken).approve(swapTarget, amount);
            (bool success, ) = swapTarget.call(swapData);
            require(success);
        }

        uint256 depositAmount = IERC20(depositToken).balanceOf(address(this));
        IERC20(depositToken).approve(vault, depositAmount);
        IPolynomialVault(vault).initiateDeposit(user, depositAmount);
    }
}
