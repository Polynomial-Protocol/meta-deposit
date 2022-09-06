// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Rocket} from "./Rocket.sol";

contract RocketFactory {
    address public owner;
    mapping(address => address) public hTokens;
    mapping(address => address) public hSwaps;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier requiresAuth() {
        require(owner == msg.sender, "UNAUTHORIZED");
        _;
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;
    }

    function deploy(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget
    ) public payable returns (address payable) {
        bytes32 uniqueSalt = keccak256(
            abi.encode(
                incomingToken,
                depositToken,
                vault,
                user,
                amount,
                swapTarget
            )
        );
        return payable(new Rocket{salt: uniqueSalt}(uniqueSalt));
    }

    function getAddressFor(
        address incomingToken,
        address depositToken,
        address vault,
        address user,
        uint256 amount,
        address swapTarget
    ) external view returns (address) {
        bytes32 salt = keccak256(
            abi.encode(
                incomingToken,
                depositToken,
                vault,
                user,
                amount,
                swapTarget
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

    function addMappings(
        address token,
        address hToken,
        address hSwap
    ) external requiresAuth {
        hTokens[token] = hToken;
        hSwaps[token] = hSwap;
    }
}
