// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Rocket} from "./Rocket.sol";

contract RocketFactory {
    function deploy(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) public payable returns (address) {
        bytes32 uniqueSalt = keccak256(
            abi.encode(
                incomingToken,
                depositToken,
                vault,
                user,
                amount,
                swapTarget,
                swapData
            )
        );
        return address(new Rocket{salt: uniqueSalt}(uniqueSalt));
    }

    function getAddressFor(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget,
        bytes memory swapData
    ) external view returns (address) {
        bytes32 salt = keccak256(
            abi.encode(
                incomingToken,
                depositToken,
                vault,
                user,
                amount,
                swapTarget,
                swapData
            )
        );
        address predictedAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            keccak256(
                                abi.encodePacked(
                                    type(Rocket).creationCode,
                                    abi.encode(salt)
                                )
                            )
                        )
                    )
                )
            )
        );

        return predictedAddress;
    }
}
