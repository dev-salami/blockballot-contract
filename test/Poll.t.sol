// SPDX-License-Identfier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {DeployPoll} from "../script/Poll.s.sol";
import {PollContract} from "../src/Poll.sol";

contract PollTest is Test {
    PollContract pollContract;

    function setUp() public returns (PollContract) {
        pollContract = new DeployPoll().run();

        return pollContract;
    }

    // function testPoll_Id_Initailize() public {
    //     assertEq(pollContract.POLL_UUID(), 0);
    // }
}
