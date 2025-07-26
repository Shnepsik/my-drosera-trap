# BalanceAnomalyTrap
**Balance Anomaly Trap — Drosera Trap SERGEANT** 

# Objective

Create a functional and deployable Drosera trap that:

- Monitors ETH balance anomalies of a specific wallet,

- Uses the standard collect() / shouldRespond() interface,

- Triggers a response when balance deviation exceeds a given threshold (e.g., 1~10%),

- Integrates with a separate alert contract to handle responses.
---

# Problem

Ethereum wallets involved in DAO treasury, DeFi protocol management, or vesting operations must maintain a consistent balance. Any unexpected change — loss or gain — could indicate compromise, human error, or exploit.

Solution: _Monitor ETH balance of a wallet across blocks. Trigger a response if there's a significant deviation in either direction._

---

# Trap Logic Summary

_Trap Contract: BalanceAnomalyTrap.sol_

_Pay attention to this string "address public constant target = 0x03Bf5F9d497354c68d1DD70578677353357A1918; // change 0x03Bf5F9d497354c68d1DD70578677353357A1918 to your own wallet address"_
```
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract EthOutflowTrap is ITrap {
    address public constant target = 0x03Bf5F9d497354c68d1DD70578677353357A1918;
    uint256 public constant thresholdPercent = 10;

    function collect() external view override returns (bytes memory) {
        return abi.encode(target.balance);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "Insufficient data");

        uint256 current = abi.decode(data[0], (uint256));
        uint256 previous = abi.decode(data[1], (uint256));

        if (current >= previous) {
            return (false, "");
        }

        uint256 diff = previous - current;
        uint256 percentDrop = (diff * 100) / previous;

        if (percentDrop >= thresholdPercent) {
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

contract TrapAlertReceiver {
    event AnomalyDetected(
        address indexed reporter,
        address indexed wallet,
        string reason,
        uint256 value
    );

    /**
     * @notice Called by the trap to report an anomaly.
     * @param wallet The wallet address where the anomaly was detected.
     * @param reason A short description of the anomaly.
     * @param value Optional numeric value (e.g. % drop, token balance, etc).
     */
    function reportAnomaly(
        address wallet,
        string calldata reason,
        uint256 value
    ) external {
        emit AnomalyDetected(msg.sender, wallet, reason, value);
    }
}
```
---

# What It Solves 

- Detects suspicious ETH flows from monitored addresses,

- Provides an automated alerting mechanism,

- Can integrate with automation logic (e.g., freezing funds, emergency DAO alerts).

- Receives data from the trap (e.g., wallet address, reason text, numeric value).

Emits an event AnomalyDetected that can be tracked via logs.

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

<img width="547" height="354" alt="{F13A1A68-C0D0-4DFE-AF0B-03BA506B3899}" src="https://github.com/Shnepsik/my-drosera-trap/blob/main/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202025-07-26%20%D0%B2%2016.55.36.png?raw=true" />


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

_First created: July 26, 2026_

## Author: Danzel && Profit_Nodes 
TG : @qbattemnt

Discord: Shnepsik

