// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {PointerworksAchievements} from "../src/PointerworksAchievements.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        vm.startBroadcast(deployerKey);
        PointerworksAchievements c = new PointerworksAchievements();
        vm.stopBroadcast();
        console2.log("PointerworksAchievements deployed at:", address(c));
    }
}
