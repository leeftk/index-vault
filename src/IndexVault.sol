// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract AIVault is Ownable {
    IUniswapV2Router02 uniswapRouter;
    ERC20 public immutable asset_;
    struct Allocation {
        address token;
        uint256 percentage; // in basis points, 10000 = 100%
    }

    Allocation[] public allocations;
    mapping(address => bool) public allowedTokens;

    constructor() ERC20("AIVault", "AIV"){
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Replace with the actual Uniswap V2 Router address
    }


    // Ensure the contract can receive ETH
    receive() external payable {}

    // Function to change allocations by the owner
    function setAllocations(Allocation[] calldata newAllocations) external onlyOwner {
        delete allocations;
        uint256 totalPercentage = 0;

        for (uint i = 0; i < newAllocations.length; ++i) {
            Allocation memory allocation = newAllocations[i];
            require(allowedTokens[allocation.token], "Token not whitelisted");
            require(allocation.percentage > 0, "Percentage must be greater than 0");
            totalPercentage += allocation.percentage;
            allocations.push(allocation);
        }

        require(totalPercentage == 10000, "Total percentage must equal 100%");
    }

    // Function to whitelist tokens
    function addToAllowedToken(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        allowedTokens[token] = true;
    }

    // Override the deposit behavior
    function deposit(uint256 assets, address receiver) public override returns (uint256 shares) {
        shares = super.deposit(assets, receiver);
        purchaseTokens(assets);
        _mint(shares, receiver);
        return shares;
    }

    // Logic for purchasing tokens based on allocations
    function purchaseTokens(uint256 amountETH, uint256 amountOutMin) internal {
        uint length = allocations.length;
        for (uint i = 0; i < length; ++i) {
            Allocation memory allocation = allocations[i];
            uint256 swapAmount = amountETH * allocation.percentage / 10000;
            require(swapAmount > 0, "Cannot swap for 0 tokens");
            swapETHForTokens(allocation.token, swapAmount, 0);
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
