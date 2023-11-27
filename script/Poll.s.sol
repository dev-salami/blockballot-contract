// SPDX-License-Identfier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {PollContract} from "../src/Poll.sol";

contract DeployPoll is Script {
    function run() public returns (PollContract) {
        vm.startBroadcast();
        PollContract pollContract = new PollContract();
        vm.stopBroadcast();

        return pollContract;
    }
}
