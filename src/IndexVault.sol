// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract AIVault is ERC4626, Ownable {
    IUniswapV2Router02 uniswapRouter;

    struct Allocation {
        address token;
        uint256 percentage; // in basis points, 10000 = 100%
    }

    Allocation[] public allocations;
    mapping(address => bool) public whitelist;

    constructor(IERC20 asset, address _uniswapRouterAddress) ERC4626(asset) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
    }

    // Ensure the contract can receive ETH
    receive() external payable {}

    // Function to change allocations by the owner
    function setAllocations(Allocation[] calldata newAllocations) external onlyOwner {
        delete allocations;
        uint256 totalPercentage = 0;

        for (uint i = 0; i < newAllocations.length; ++i) {
            require(whitelist[newAllocations[i].token], "Token not whitelisted");
            require(newAllocations[i].percentage > 0, "Percentage must be greater than 0");
            totalPercentage += newAllocations[i].percentage;
            allocations.push(newAllocations[i]);
        }

        require(totalPercentage == 10000, "Total percentage must equal 100%");
    }

    // Function to whitelist tokens
    function addToWhitelist(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        whitelist[token] = true;
    }

    // Override the deposit behavior
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        shares = super.deposit(assets, receiver);
        purchaseTokens(assets);
        return shares;
    }

    // Logic for purchasing tokens based on allocations
    function purchaseTokens(uint256 amountETH) internal {
        for (uint i = 0; i < allocations.length; i++) {
            Allocation memory allocation = allocations[i];
            uint256 swapAmount = amountETH * allocation.percentage / 10000;
            require(swapAmount > 0, "Cannot swap for 0 tokens");
            swapETHForTokens(allocation.token, swapAmount, 0); // 0 as minimum amount out for simplicity
        }
    }

    // Swap ETH for tokens using Uniswap
    function swapETHForTokens(address token, uint256 amountETH, uint amountOutMin) internal {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = token;
        uint256 deadline = block.timestamp + 300;

        uniswapRouter.swapExactETHForTokens{ value: amountETH }(
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }

    // Additional functions as needed...
}
