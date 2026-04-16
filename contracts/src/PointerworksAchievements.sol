// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Pointerworks — on-chain level completion ledger.
/// @notice Each player records a completion bit per level (0..9).
///         Re-submits are idempotent and cheap. The solution hash is
///         stored alongside the first completion so anti-cheese logic
///         can be added later without changing storage layout.
/// @dev    Written for Gamedev.js Jam 2026 Ethereum side challenge.
contract PointerworksAchievements {
    /// Total levels in the Pointerworks game.
    uint8 public constant LEVEL_COUNT = 10;

    /// Bitmap of completed levels per player. Bit `levelId` set = solved.
    mapping(address => uint16) public completedBitmap;

    /// Per-player, per-level deterministic solution hash.
    mapping(address => mapping(uint8 => bytes32)) public solutionHash;

    event LevelCompleted(
        address indexed player,
        uint8 indexed levelId,
        bytes32 hash,
        uint64 timestamp
    );

    error InvalidLevel(uint8 levelId);

    /// @notice Record completion of `levelId` by msg.sender.
    /// @dev    Idempotent. First call stores the hash; subsequent calls
    ///         emit a fresh event but do not overwrite the stored hash
    ///         (favours the first provable solution).
    function completeLevel(uint8 levelId, bytes32 hash) external {
        if (levelId >= LEVEL_COUNT) {
            revert InvalidLevel(levelId);
        }
        uint16 mask = uint16(1) << levelId;
        if ((completedBitmap[msg.sender] & mask) == 0) {
            completedBitmap[msg.sender] |= mask;
            solutionHash[msg.sender][levelId] = hash;
        }
        emit LevelCompleted(msg.sender, levelId, hash, uint64(block.timestamp));
    }

    /// @notice Convenience view — how many levels `player` has cleared.
    function completedCount(address player) external view returns (uint8 count) {
        uint16 bits = completedBitmap[player];
        for (uint8 i = 0; i < LEVEL_COUNT; ++i) {
            if ((bits & (uint16(1) << i)) != 0) {
                unchecked { ++count; }
            }
        }
    }

    /// @notice Convenience view — has `player` cleared `levelId`?
    function hasCompleted(address player, uint8 levelId) external view returns (bool) {
        if (levelId >= LEVEL_COUNT) return false;
        return (completedBitmap[player] & (uint16(1) << levelId)) != 0;
    }
}
