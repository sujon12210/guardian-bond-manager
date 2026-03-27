const { ethers } = require("ethers");
require("dotenv").config();

async function checkBondHealth() {
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
    const botWallet = new ethers.Wallet(process.env.BOT_PRIVATE_KEY, provider);
    
    // UMA Optimistic Oracle V3 Interface
    const oracle = new ethers.Contract(process.env.ORACLE_ADDRESS, [
        "function getMinimumBond(address collateral) view returns (uint256)"
    ], provider);

    const minBond = await oracle.getMinimumBond(process.env.WETH_ADDRESS);
    const botBalance = await provider.getBalance(botWallet.address);

    console.log(`Min Bond Required: ${ethers.formatEther(minBond)} ETH`);
    console.log(`Bot Balance: ${ethers.formatEther(botBalance)} ETH`);

    // Safety margin: ensure we can cover at least 3 disputes
    if (botBalance < (minBond * 3n)) {
        console.warn("Low balance! Triggering refill from BondManager...");
        const manager = new ethers.Contract(process.env.MANAGER_ADDRESS, [
            "function requestRefill() external"
        ], botWallet);
        
        const tx = await manager.requestRefill();
        await tx.wait();
        console.log("Refill successful.");
    }
}

setInterval(checkBondHealth, 3600000); // Run every hour
