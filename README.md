# AIVault
[Git Source](https://github.com/leeftk/index-vault/blob/cc48d1747629c1c903833a7709a28c4102ed65a2/src/IndexVault.sol)

**Inherits:**
ERC4626, Ownable


## State Variables
### uniswapRouter

```solidity
IUniswapV2Router02 uniswapRouter;
```


### allocations

```solidity
Allocation[] public allocations;
```


### whitelist

```solidity
mapping(address => bool) public whitelist;
```


## Functions
### constructor


```solidity
constructor(IERC20 asset, address _uniswapRouterAddress) ERC4626(asset);
```

### receive


```solidity
receive() external payable;
```

### setAllocations


```solidity
function setAllocations(Allocation[] calldata newAllocations) external onlyOwner;
```

### addToWhitelist


```solidity
function addToWhitelist(address token) external onlyOwner;
```

### deposit


```solidity
function deposit(uint256 assets, address receiver) public override returns (uint256 shares);
```

### purchaseTokens


```solidity
function purchaseTokens(uint256 amountETH) internal;
```

### swapETHForTokens


```solidity
function swapETHForTokens(address token, uint256 amountETH, uint256 amountOutMin) internal;
```

## Structs
### Allocation

```solidity
struct Allocation {
    address token;
    uint256 percentage;
}
```

