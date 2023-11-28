// SPDX-License-Identfier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {DeployPoll} from "../script/Poll.s.sol";
import {PollContract} from "../src/Poll.sol";

contract PollTest is Test {
    PollContract pollContract;
    address constant CREATOR = address(1);
    address constant USER1 = address(2);
    address constant USER2 = address(3);

    bool constant PUBLIC_ACCESS = false;
    address[] WHITELIST = [USER1, USER2];
    string constant QUESTION = "Who are you ?";
    string[] OPTIONS = ["Ade", "Bola", "Titi"];
    modifier MakePoll() {
        vm.startPrank(CREATOR);
        pollContract.CreatePoll(PUBLIC_ACCESS, WHITELIST, QUESTION, OPTIONS);
        vm.stopPrank();
        _;
    }

    function setUp() public returns (PollContract) {
        pollContract = new DeployPoll().run();

        return pollContract;
    }

    function testPoll_Id_Initailize() public {
        assertEq(pollContract.POLL_UUID(), 0);
    }

    // function testCreatePoll() public MakePoll {
    //     assertEq(pollContract.POLL_UUID(), 1);
    // }

    function testPoll_Data_Update() public MakePoll {
        // assertEq(pollContract.UserPolls()[msg.sender], 0);
        vm.startPrank(CREATOR);
        console.log(pollContract.getSinglePoll(0).Creator);
        assertEq(pollContract.getSinglePoll(0).Creator, CREATOR);
        assertEq(pollContract.getUserPolls().length, 1);
        assertEq(pollContract.POLL_UUID(), 1);
        vm.expectEmit();
    }
}
