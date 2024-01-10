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

contract MulticallSwapAdd {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    //diff EVM chain diff wrapped token address.
    IWETH9 wrapped;
    RangeProtocolVault vaultCtx;

    constructor(address wrappedTokenAddress) public {
        wrapped = IWETH9(wrappedTokenAddress);
    }

    //events
    event SwapAdded();
    event SwapRemoved();
    event SwapAddedBase();
    event SwapRemovedBase();

    //allow base token swap add.

    struct SwapData {
        address target;
        address token0;
        address token1;
        address vault;
        bool zeroForOne;
        uint256 amount;
        string signature;
        bytes callData;
    }
    //Stake and add using base 
    struct StakeData {
        address target;
        address token0;
        address token1;
        address vault;
        address stakingCtx; 
        bool staked0; 
        uint256 amount;
        string signature;
        bytes callData;
    }

    // function stakeAddBase(bytes calldata data) external payable{
    //     StakeData memory stakeData = abi.decode(data, (StakeData));

    //     //1. Wrap ETH to WETH

    //     //we only deposit some ETH to WETH
    //     wrapped.deposit{value: msg.value- stakeData.amount}();

    //     console.log(stakeData.token0);
    //     console.log(stakeData.token1);


    //     //2. Stake some ETH to wstETH
    //     //should enter stakingCtx receive function, and mint wstETH to this contract

    //     //depending on staking ctx and implementation, we call accordingly. 
    //     Address.functionCall{value: stakeData.amount}(stakeData.stakingCtx, stakeData.callData)
    //     // (stakeData.stakingCtx).call{value: stakeData.amount}();



    //     //4. approve vault for mint
    //     //amount 0 for mint : the eth we had initially - the amount that we used for swapped + residual amounts not utilised in swap
    //     //amount 1 for mint: swapped amount for 1.
    //     uint256 amount0;
    //     uint256 amount1;
    //     uint256 mintAmount;

    //     //3.Get mint amounts using WETH and wstETH 
    //     (amount0, amount1, mintAmount) = IRangeProtocolVault(stakeData.vault).getMintAmounts(
    //         IERC20Upradeable(stakeData.token0).balanceOf(address(this)), 
    //         IERC20Upradeable(stakeData.token1).balanceOf(address(this))
    //     );
    

    //     IERC20Upgradeable(stakeData.token0).approve(address(stakeData.vault), amount0);
    //     IERC20Upgradeable(stakeData.token1).approve(address(stakeData.vault), amount1);
    //     //5. mint position
    //     bytes memory mintData;
    //     if (
    //         keccak256(abi.encodePacked(stakeData.signature)) ==
    //         keccak256(abi.encodePacked("mint(uint256)"))
    //     ) {
    //         mintData = abi.encodeWithSignature("mint(uint256)", mintAmount);
    //     } else {
    //         mintData = abi.encodeWithSignature(
    //             "mint(uint256,uint256[2])",
    //             mintAmount,
    //             [amount0, amount1]
    //         );
    //     }

    //     //5a. call mint on Vault
    //     Address.functionCall(address(stakeData.vault), mintData);
    //     //7. Transfer LP token back to user if not reverted.
    //     IERC20Upgradeable(stakeData.vault).transfer(msg.sender, mintAmount);

    // }


    //Swap and add using base network currency.
    function swapAddBase(bytes calldata data) external payable {
        //1. Decoding bytes to required data
        //target: native target contract
        //token0: token0 that we are using for swap
        //token1: token1 that we are using for swap.
        //vault: which vault are we interacting with
        //zeroForOne: direction of swap
        //amount: amount used in swap
        //swapData: generated from Native

        SwapData memory swapData = abi.decode(data, (SwapData));

        //2. Wrap ETH to WETH
        // console.log(msg.value);
        // console.log(swapData.callData);
        //deposit using multicall ctx
        wrapped.deposit{value: msg.value}();
        // console.log(swapData.target);
        //3. swap on Native.
        // if swap 0->1, approve 0 to Native.
        console.log(swapData.token0);
        console.log(swapData.token1);
        if (swapData.zeroForOne) {
            // console.log(swapData.zeroForOne);
            IERC20Upgradeable(swapData.token0).approve(swapData.target, swapData.amount);
        } else {
            IERC20Upgradeable(swapData.token1).approve(swapData.target, swapData.amount);
        }
        // {
        //     uint256 allowance0 = IERC20Upgradeable(swapData.token0).allowance(address(this), swapData.target);
        //     uint256 allowance1 = IERC20Upgradeable(swapData.token1).allowance(address(this), swapData.target);
        //     // console.log(allowance0);
        //     // console.log(allowance1);
        //     // console.log("allowance");
        // }
        //returned amounts from swap. so if zeroForOne if either is non-zero, I need to return to user.

        // console.log(swapData.target);
        uint256 balance0Before = IERC20Upgradeable(swapData.token0).balanceOf(address(this));
        uint256 balance1Before = IERC20Upgradeable(swapData.token1).balanceOf(address(this));
        // Address.functionCall(target,swapData);
        // console.log(balance0Before);
        // console.log(balance1Before);
        // (bool successSwap, bytes memory swapReturn) = (swapData.target).call(swapData.callData);
        Address.functionCall(swapData.target, swapData.callData);
        console.log("swap ok");
        uint256 balance0After = IERC20Upgradeable(swapData.token0).balanceOf(address(this));
        uint256 balance1After = IERC20Upgradeable(swapData.token1).balanceOf(address(this));
        // uint256 balance0After = IERC20Upgradeable(token0).balanceOf(address(this));;;
        // uint256 balance1After = IERC20Upgradeable(token1).balanceOf(address(this));
        uint256 swapped0;
        uint256 swapped1;
        if (swapData.zeroForOne) {
            swapped0 = balance0Before - balance0After;
            swapped1 = balance1After - balance1Before;
        } else {
            swapped0 = balance0After - balance0Before;
            swapped1 = balance1Before - balance1After;
        }

        // console.log(swapped0);
        // console.log(swapped1);

        //4. approve vault for mint
        //amount 0 for mint : the eth we had initially - the amount that we used for swapped + residual amounts not utilised in swap
        //amount 1 for mint: swapped amount for 1.
        uint256 amount0;
        uint256 amount1;
        uint256 mintAmount;
        if (swapData.zeroForOne) {
            (amount0, amount1, mintAmount) = IRangeProtocolVault(swapData.vault).getMintAmounts(
                msg.value - swapData.amount + (swapData.amount - swapped0),
                swapped1
            );
        } else {
            (amount0, amount1, mintAmount) = IRangeProtocolVault(swapData.vault).getMintAmounts(
                swapped0,
                msg.value - swapData.amount + (swapData.amount - swapped1)
            );
        }

        IERC20Upgradeable(swapData.token0).approve(address(swapData.vault), amount0);
        IERC20Upgradeable(swapData.token1).approve(address(swapData.vault), amount1);
        //5. mint position
        bytes memory mintData;
        if (
            keccak256(abi.encodePacked(swapData.signature)) ==
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
        Address.functionCall(address(swapData.vault), mintData);

        //5b. check how much of mint amounts are used
        //minted0 is amount0 used, minted1 is amount1 used.
        // (uint256 minted0, uint256 minted1) = abi.decode(mintReturn, (uint256, uint256));

        //6. Transfer unused WETH
        //so there should be some amounts that are not transferred as well.
        //essentially whats need to be transferred back should be
        //initial WETH - minted WETH unless
        IERC20Upgradeable(swapData.token0).transfer(msg.sender, address(this).balance);
        IERC20Upgradeable(swapData.token1).transfer(msg.sender, address(this).balance);

        //7. Transfer LP token back to user if not reverted.
        IERC20Upgradeable(swapData.vault).transfer(msg.sender, mintAmount);
    }

    //can be any non base token.

    function swapAdd(bytes calldata data, uint256 initialAmount) external {


        SwapData memory swapData = abi.decode(data, (SwapData));
       

        //1. Transfer from initial asset
        console.log(swapData.token0);
        console.log(swapData.token1);
        if (swapData.zeroForOne) {
            // console.log(swapData.zeroForOne);
            IERC20Upgradeable(swapData.token0).transferFrom(msg.sender, address(this), initialAmount);
            IERC20Upgradeable(swapData.token0).approve(swapData.target, swapData.amount);
        } else {
            IERC20Upgradeable(swapData.token1).transferFrom(msg.sender,address(this), initialAmount);
            IERC20Upgradeable(swapData.token1).approve(swapData.target, swapData.amount);
        }
        // {
        // console.log(swapData.target);
        uint256 balance0Before = IERC20Upgradeable(swapData.token0).balanceOf(address(this));
        uint256 balance1Before = IERC20Upgradeable(swapData.token1).balanceOf(address(this));
        // console.log(balance0Before);
        // console.log(balance1Before);
        Address.functionCall(swapData.target, swapData.callData);
        console.log("swap ok");
        uint256 balance0After = IERC20Upgradeable(swapData.token0).balanceOf(address(this));
        uint256 balance1After = IERC20Upgradeable(swapData.token1).balanceOf(address(this));
        // uint256 balance0After = IERC20Upgradeable(token0).balanceOf(address(this));;;
        // uint256 balance1After = IERC20Upgradeable(token1).balanceOf(address(this));
        uint256 swapped0;
        uint256 swapped1;
        if (swapData.zeroForOne) {
            swapped0 = balance0Before - balance0After;
            swapped1 = balance1After - balance1Before;
        } else {
            swapped0 = balance0After - balance0Before;
            swapped1 = balance1Before - balance1After;
        }
        // console.log(swapped0);
        // console.log(swapped1);
        //4. approve vault for mint
        //amount 0 for mint : the eth we had initially - the amount that we used for swapped + residual amounts not utilised in swap
        //amount 1 for mint: swapped amount for 1.
        uint256 amount0;
        uint256 amount1;
        uint256 mintAmount;
        if (swapData.zeroForOne) {
            (amount0, amount1, mintAmount) = IRangeProtocolVault(swapData.vault).getMintAmounts(
                balance0Before - swapData.amount + (swapData.amount - swapped0),
                swapped1
            );
        } else {
            (amount0, amount1, mintAmount) = IRangeProtocolVault(swapData.vault).getMintAmounts(
                swapped0,
                balance1Before - swapData.amount + (swapData.amount - swapped1)
            );
        }

        IERC20Upgradeable(swapData.token0).approve(address(swapData.vault), amount0);
        IERC20Upgradeable(swapData.token1).approve(address(swapData.vault), amount1);
        //5. mint position
        bytes memory mintData;
        if (
            keccak256(abi.encodePacked(swapData.signature)) ==
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
        Address.functionCall(address(swapData.vault), mintData);

        //6. Transfer unused WETH
        //so there should be some amounts that are not transferred as well.
        //essentially whats need to be transferred back should be
        //initial WETH - minted WETH unless
        IERC20Upgradeable(swapData.token0).transfer(
            msg.sender,
            IERC20Upgradeable(swapData.token0).balanceOf(address(this))
        );
        IERC20Upgradeable(swapData.token1).transfer(
            msg.sender,
            IERC20Upgradeable(swapData.token1).balanceOf(address(this))
        );

        //7. Transfer LP token to user if not reverted.
        IERC20Upgradeable(swapData.vault).transfer(msg.sender, mintAmount);
    }

    function swapRemoveBase(bytes memory data) external {
        SwapData memory swapData = abi.decode(data, (SwapData));

        //1. transfer LP token back to multicall contract, requires approval of LP token prior
        IERC20Upgradeable(swapData.vault).transferFrom(msg.sender, address(this), swapData.amount);
        (uint256 burn0, uint256 burn1) = IRangeProtocolVault(swapData.vault)
            .getUnderlyingBalancesByShare(swapData.amount);
        //2. burn
        bytes memory burnData;
        if (
            keccak256(abi.encodePacked(swapData.signature)) ==
            keccak256(abi.encodePacked("burn(uint256)"))
        ) {
            burnData = abi.encodeWithSignature("burn(uint256)", swapData.amount);
        } else {
            burnData = abi.encodeWithSignature(
                "burn(uint256,uint256[2])",
                swapData.amount,
                [burn0, burn1]
            );
        }
        Address.functionCall(address(swapData.vault), burnData);
        //3. approve native router
        //Convert base token back to non base token.
        //amount here is LP token.
        if (swapData.zeroForOne) {
            IERC20Upgradeable(swapData.token0).approve(swapData.target, type(uint256).max);
            //4. swap to weth
            Address.functionCall(swapData.target, swapData.callData);
            wrapped.withdrawTo(
                msg.sender,
                IERC20Upgradeable(swapData.token1).balanceOf(address(this))
            );
            //transfer possible residual amounts of other token back to user
            IERC20Upgradeable(swapData.token0).approve(swapData.target, 0);

            IERC20Upgradeable(swapData.token0).transfer(
                msg.sender,
                IERC20Upgradeable(swapData.token0).balanceOf(address(this))
            );
        } else {
            IERC20Upgradeable(swapData.token1).approve(swapData.target, type(uint256).max);
            Address.functionCall(swapData.target, swapData.callData);
            wrapped.withdrawTo(
                msg.sender,
                IERC20Upgradeable(swapData.token0).balanceOf(address(this))
            );
            //transfer possible residual amounts of other token back to user
            IERC20Upgradeable(swapData.token1).approve(swapData.target, 0);

            IERC20Upgradeable(swapData.token1).transfer(
                msg.sender,
                IERC20Upgradeable(swapData.token1).balanceOf(address(this))
            );
        }
    }

    function swapRemove(bytes memory data) external {
        SwapData memory swapData = abi.decode(data, (SwapData));

        //1. transfer LP token back to multicall contract, requires approval of LP token prior
        IERC20Upgradeable(swapData.vault).transferFrom(msg.sender, address(this), swapData.amount);

        (uint256 burn0, uint256 burn1) = IRangeProtocolVault(swapData.vault)
            .getUnderlyingBalancesByShare(swapData.amount);
        //2. burn
        bytes memory burnData;
        if (
            keccak256(abi.encodePacked(swapData.signature)) ==
            keccak256(abi.encodePacked("burn(uint256)"))
        ) {
            burnData = abi.encodeWithSignature("burn(uint256)", swapData.amount);
        } else {
            burnData = abi.encodeWithSignature(
                "burn(uint256,uint256[2])",
                swapData.amount,
                [burn0, burn1]
            );
        }
        Address.functionCall(address(swapData.vault), burnData);

        //3. approve native router
        //now is native token back to non native token.
        //so in calldata should state accordingly.
        //amount here is LP token.

        if (swapData.zeroForOne) {
            IERC20Upgradeable(swapData.token0).approve(swapData.target, type(uint256).max);

            Address.functionCall(swapData.target, swapData.callData);
            IERC20Upgradeable(swapData.token0).approve(swapData.target, 0);
        } else {
            IERC20Upgradeable(swapData.token1).approve(swapData.target, type(uint256).max);

            Address.functionCall(swapData.target, swapData.callData);
            IERC20Upgradeable(swapData.token1).approve(swapData.target, 0);
        }
        //4. send both token back to user
        IERC20Upgradeable(swapData.token0).transfer(
            msg.sender,
            IERC20Upgradeable(swapData.token0).balanceOf(address(this))
        );
        IERC20Upgradeable(swapData.token1).transfer(
            msg.sender,
            IERC20Upgradeable(swapData.token1).balanceOf(address(this))
        );
    }


}
