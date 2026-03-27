# Guardian Bond Manager

To protect a DAO optimistically, the Guardian must be "liquid." If a malicious actor asserts a false result, but the Guardian has 0 ETH to post a dispute bond, the attack succeeds. This manager automates the capital requirements of a security bot.

## Key Features
* **Threshold Monitoring**: Checks the Guardian's wallet balance against the UMA Oracle's `minimumBond` requirement.
* **Auto-Replenish**: Pulls collateral from a "Backstop Vault" if the balance drops below a safety threshold.
* **Reward Recycler**: Automatically claims rewards from won disputes and returns the original bond to the working pool.

## Workflow
1. **Sync**: Fetch the current `finalityBond` from the Optimistic Oracle.
2. **Check**: Compare wallet balance to `2x` the bond (to allow for multiple simultaneous disputes).
3. **Refill**: If low, trigger a transfer from the DAO Treasury or a pre-funded Buffer contract.
