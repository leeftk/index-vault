// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AIVault.sol"; // Update this path to the actual path of your AIVault contract

contract AIVaultTest is Test {
    AIVault vault;
    address uniswapRouterAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Replace with the actual Uniswap V2 Router address

    function setUp() public {
        // Initialize your AIVault contract with the Uniswap router address
        vault = new AIVault(uniswapRouterAddress);
    }

    function testSwapETHForTokens() public {
        // Arrange: Set up the necessary conditions for your test
        address tokenAddress = 0x...; // Replace with the actual token address you want to swap to
        uint256 amountETH = 1 ether;

        // Act: Call the function you want to test
        vault.swapETHForTokens(tokenAddress, amountETH);

        // Assert: Check the results of your function call
        assertEq(IERC20(tokenAddress).balanceOf(address(vault)), expectedTokenAmount);
        // You'll need to calculate the `expectedTokenAmount` based on the current exchange rate
    }

    // Additional tests as needed...
}
