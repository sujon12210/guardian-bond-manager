// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondManager is Ownable {
    IERC20 public collateralToken;
    address public guardianBot;
    uint256 public refillThreshold;

    event FundsRefilled(address indexed bot, uint256 amount);

    constructor(address _token, address _bot, uint256 _threshold) Ownable(msg.sender) {
        collateralToken = IERC20(_token);
        guardianBot = _bot;
        refillThreshold = _threshold;
    }

    /**
     * @dev Replenishes the Guardian bot's wallet.
     * Can be called by the bot itself when it detects low funds.
     */
    function requestRefill() external {
        require(msg.sender == guardianBot || msg.sender == owner(), "Unauthorized");
        
        uint256 currentBalance = collateralToken.balanceOf(guardianBot);
        if (currentBalance < refillThreshold) {
            uint256 amountToTransfer = refillThreshold - currentBalance;
            require(collateralToken.transfer(guardianBot, amountToTransfer), "Transfer failed");
            emit FundsRefilled(guardianBot, amountToTransfer);
        }
    }

    function updateThreshold(uint256 _newThreshold) external onlyOwner {
        refillThreshold = _newThreshold;
    }
}
