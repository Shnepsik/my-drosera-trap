# BalanceAnomalyTrap
**Balance Anomaly Trap — Drosera Trap SERGEANT** 

# Objective

Create a functional and deployable Drosera trap that:

- Monitors ETH balance anomalies of a specific wallet,

- Uses the standard collect() / shouldRespond() interface,

- Triggers a response when balance deviation exceeds a given threshold (e.g., 1%),

- Integrates with a separate alert contract to handle responses.
---

# Problem

Ethereum wallets involved in DAO treasury, DeFi protocol management, or vesting operations must maintain a consistent balance. Any unexpected change — loss or gain — could indicate compromise, human error, or exploit.

Solution: _Monitor ETH balance of a wallet across blocks. Trigger a response if there's a significant deviation in either direction._

---

# Trap Logic Summary

_Trap Contract: BalanceAnomalyTrap.sol_

_Pay attention to this string "address public constant target = 0xABcDEF1234567890abCDef1234567890AbcDeF12; // change 0xABcDEF1234567890abCDef1234567890AbcDeF12 to your own wallet address"_
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory);
}

contract BalanceAnomalyTrap is ITrap {
    address public constant target = 0xABcDEF1234567890abCDef1234567890AbcDeF12; // change 0xABcDEF1234567890abCDef1234567890AbcDeF12 to your own wallet address
    uint256 public constant thresholdPercent = 1;

    function collect() external override returns (bytes memory) {
        return abi.encode(target.balance);
    }

    function shouldRespond(bytes[] calldata data) external view override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        uint256 diff = current > previous ? current - previous : previous - current;
        uint256 percent = (diff * 100) / previous;

        if (percent >= thresholdPercent) {
            return (true, "");
        }

        return (false, "");
    }
}
```

# Response Contract: LogAlertReceiver.sol
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogAlertReceiver {
    event Alert(string message);

    function logAnomaly(string calldata message) external {
        emit Alert(message);
    }
}
```
---

# What It Solves 

- Detects suspicious ETH flows from monitored addresses,

- Provides an automated alerting mechanism,

- Can integrate with automation logic (e.g., freezing funds, emergency DAO alerts).

---

# Deployment & Setup Instructions 

1. ## _Deploy Contracts (e.g., via Foundry)_ 
```
forge create src/BalanceAnomalyTrap.sol:BalanceAnomalyTrap \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...
```
```
forge create src/LogAlertReceiver.sol:LogAlertReceiver \
  --rpc-url https://ethereum-hoodi-rpc.publicnode.com \
  --private-key 0x...
```
2. ## _Update drosera.toml_ 
```
[traps.mytrap]
path = "out/BalanceAnomalyTrap.sol/BalanceAnomalyTrap.json"
response_contract = "<LogAlertReceiver address>"
response_function = "logAnomaly(string)"
```
3. ## _Apply changes_ 
```
DROSERA_PRIVATE_KEY=0x... drosera apply
```

<img width="547" height="354" alt="{F13A1A68-C0D0-4DFE-AF0B-03BA506B3899}" src="https://github.com/user-attachments/assets/e4ad73d9-5d32-4b65-9803-41c9872d3e4c" />


# Testing the Trap 

1. Send ETH to/from target address on Ethereum Hoodi testnet.

2. Wait 1-3 blocks.

3. Observe logs from Drosera operator:

4. get ShouldRespond='true' in logs and Drosera dashboard
---

# Extensions & Improvements 

- Allow dynamic threshold setting via setter,

- Track ERC-20 balances in addition to native ETH,

- Chain multiple traps using a unified collector.


# Date & Author

_First created: July 10, 2025_

## Author: Danzel && Profit_Nodes 
TG : _@Danzeliti_

Discord: _danzel99_

