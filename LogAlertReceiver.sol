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
