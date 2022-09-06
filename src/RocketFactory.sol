// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {Rocket} from "./Rocket.sol";

contract RocketFactory {
    using FixedPointMathLib for uint256;

    address public owner;
    address public feeReceipient;
    uint256 public feeRate;

    mapping(address => address) public hTokens;
    mapping(address => address) public hSwaps;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier requiresAuth() {
        require(owner == msg.sender, "UNAUTHORIZED");
        _;
    }

    function setOwner(address newOwner) external requiresAuth {
        owner = newOwner;
    }

    function setFeeReceipient(address _feeReceipient) external requiresAuth {
        feeReceipient = _feeReceipient;
    }

    function setFee(uint256 _feeRate) external requiresAuth {
        feeRate = _feeRate;
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

    function getFee(address depositToken, uint256 depositAmount)
        external
        view
        returns (address receipient, uint256 fee)
    {
        receipient = feeReceipient;
        fee = depositAmount.mulWadDown(feeRate);
    }

    function addMappings(
        address token,
        address hToken,
        address hSwap
    ) external requiresAuth {
        hTokens[token] = hToken;
        hSwaps[token] = hSwap;
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
}
