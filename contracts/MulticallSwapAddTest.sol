//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {RangeProtocolVault} from "./RangeProtocolVault.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";
import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {SafeCastUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {SafeERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IRangeProtocolVault} from "./interfaces/IRangeProtocolVault.sol";
import "hardhat/console.sol";

contract MulticallSwapAddTest{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    //diff EVM chain diff wrapped token address.
    IWETH9 wrapped;
    RangeProtocolVault vaultCtx;

    constructor(address wrappedTokenAddress) public {
        wrapped = IWETH9(wrappedTokenAddress);
    }

    //allow base token swap add.

    struct SwapAddData{
        address target;
        address token0;
        address token1;
        address vault;
        bool zeroForOne;
        uint256 amount;
        string mintSignature;
        bytes callData;
    }
    //Swap and add using base network currency.
    function swapAddBase(bytes calldata data) external payable returns (bytes[] memory results) {
        //1. Decoding bytes to required data
        //target: native target contract
        //token0: token0 that we are using for swap
        //token1: token1 that we are using for swap.
        //vault: which vault are we interacting with
        //zeroForOne: direction of swap
        //amount: amount used in swap
        //swapData: generated from Native

        // (
        //     address target,
        //     address token0,
        //     address token1,
        //     address vault,
        //     bool zeroForOne,
        //     uint256 amount,
        //     string memory mintSignature,
        //     bytes memory swapData
        // ) = abi.decode(data, (address, address, address, address, bool, uint256, string, bytes));
         (
            SwapAddData memory swapData
        ) = abi.decode(data, (SwapAddData));

        //2. Wrap ETH to WETH
        // console.log(msg.value);
        // console.log(swapData.callData);
        //deposit using multicall ctx
        wrapped.deposit{value: msg.value}();
        console.log(swapData.target);
        //3. swap on Native.
        // if swap 0->1, approve 0 to Native.
        if (swapData.zeroForOne) {
            console.log(swapData.zeroForOne);
            IERC20Upgradeable(swapData.token0).approve(swapData.target, swapData.amount);
        } else {
            IERC20Upgradeable(swapData.token1).approve(swapData.target, swapData.amount);
        }
        {
            uint256 allowance0 = IERC20Upgradeable(swapData.token0).allowance(address(this), swapData.target);
            uint256 allowance1 = IERC20Upgradeable(swapData.token1).allowance(address(this), swapData.target);
            console.log(allowance0);
            console.log(allowance1);
            console.log("allowance");
        }
        //returned amounts from swap. so if zeroForOne if either is non-zero, I need to return to user.

        console.log(swapData.target);
        uint256 balance0Before = IERC20Upgradeable(swapData.token0).balanceOf(address(this));
        uint256 balance1Before = IERC20Upgradeable(swapData.token1).balanceOf(address(this));
        // Address.functionCall(target,swapData);
        console.log(balance0Before);
        console.log(balance1Before);
        (bool success, bytes memory swapReturn) = (swapData.target).call(swapData.callData);
        Address.functionCall(swapData.target, swapReturn);
        uint256 balance0After = IERC20Upgradeable(swapData.token0).balanceOf(address(this));
        uint256 balance1After = IERC20Upgradeable(swapData.token1).balanceOf(address(this));
        // uint256 balance0After = IERC20Upgradeable(token0).balanceOf(address(this));;;
        // uint256 balance1After = IERC20Upgradeable(token1).balanceOf(address(this));
        uint256 swapped0 = IERC20Upgradeable(swapData.token0).balanceOf(address(this)) - balance0Before;
        uint256 swapped1 = IERC20Upgradeable(swapData.token1).balanceOf(address(this)) - balance1Before;
        console.log(swapped0);
        console.log(swapped1);
        //4. approve vault for mint
        IERC20Upgradeable(swapData.token0).approve(address(swapData.vault), swapped0);
        IERC20Upgradeable(swapData.token1).approve(address(swapData.vault), swapped1);

        (uint256 amount0, uint256 amount1, uint256 mintAmount) = IRangeProtocolVault(swapData.vault)
            .getMintAmounts(swapped0, swapped1);
        //5. mint position
        bytes memory mintData;
        if (
            keccak256(abi.encodePacked(swapData.mintSignature)) ==
            keccak256(abi.encodePacked("mint(uint256)"))
        ) {
            mintData = abi.encodeWithSignature("mint(uint256)", mintAmount);
        } else {
            mintData = abi.encodeWithSignature(
                "mint(uint256,uint256[2])",
                mintAmount,
                [amount0, amount1]
            );
        }

        //5a. call mint on Vault
        bytes memory mintReturn = Address.functionCall(address(swapData.vault), mintData);

        //5b. check how much of mint amounts are used
        (uint256 minted0, uint256 minted1) = abi.decode(mintReturn, (uint256, uint256));

        // if(minted0 < ){
        //     IERC20(token0).transfer(msg.sender, (-minted0))
        // }

        //6. Transfer LP token back to user if not reverted.
        IERC20Upgradeable(swapData.vault).transfer(msg.sender, mintAmount);
    }
}
