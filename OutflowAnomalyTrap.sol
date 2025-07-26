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

