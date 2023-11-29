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
    bool constant PUBLIC_ACCESS_TRUE = true;
    uint256 constant POLL_OPTION_SELECTED = 1;
    uint256 constant POLL_INDEX = 1;

    address[] WHITELIST = [USER1, USER2];
    string constant QUESTION = "Who are you ?";
    string[] OPTIONS = ["Ade", "Bola", "Titi"];
    modifier MakePoll() {
        vm.startPrank(CREATOR);
        pollContract.CreatePoll(PUBLIC_ACCESS, WHITELIST, QUESTION, OPTIONS);
        vm.stopPrank();
        _;
    }
    modifier UsePoll() {
        vm.startPrank(USER1);
        pollContract.usePoll(POLL_INDEX, POLL_OPTION_SELECTED);
        vm.stopPrank();
        _;
    }
    modifier ClosePoll() {
        vm.startPrank(CREATOR);
        pollContract.endPoll(POLL_INDEX);
        vm.stopPrank();
        _;
    }
    modifier MakePoll_Public_Access() {
        vm.startPrank(CREATOR);
        pollContract.CreatePoll(
            PUBLIC_ACCESS_TRUE,
            WHITELIST,
            QUESTION,
            OPTIONS
        );
        vm.stopPrank();
        _;
    }

    function setUp() public returns (PollContract) {
        pollContract = new DeployPoll().run();

        return pollContract;
    }

    // function testPoll_Id_Initailize() public {
    //     assertEq(pollContract.POLL_UUID(), 0);
    // }

    function testPoll_Data_Update() public MakePoll {
        // assertEq(pollContract.UserPolls()[msg.sender], 0);
        vm.startPrank(CREATOR);
        console.log(pollContract.getSinglePoll(1).Creator);
        assertEq(pollContract.getSinglePoll(POLL_INDEX).Creator, CREATOR);
        assertEq(pollContract.getUserPolls().length, 1);
        assertEq(pollContract.POLL_UUID(), 1);
        // vm.expectEmit();
    }

    function testPoll_Creator_Cannot_Partake() public MakePoll {
        vm.startPrank(CREATOR);
        vm.expectRevert("Creator cannot participate");
        pollContract.usePoll(POLL_INDEX, POLL_OPTION_SELECTED);
    }

    function testPoll_Invalid_Id() public MakePoll {
        vm.expectRevert();
        vm.startPrank(USER1);
        pollContract.usePoll(7, POLL_OPTION_SELECTED);
        vm.stopPrank();
    }

    function testPoll_AlreadyVoted() public MakePoll UsePoll {
        vm.startPrank(USER1);
        vm.expectRevert();
        pollContract.usePoll(POLL_INDEX, POLL_OPTION_SELECTED);
    }

    function testPoll_NotWhiteListed() public MakePoll {
        vm.startPrank(address(9));
        vm.expectRevert();
        pollContract.usePoll(POLL_INDEX, POLL_OPTION_SELECTED);
    }

    function testPoll_Closed() public MakePoll ClosePoll {
        vm.startPrank(USER1);
        vm.expectRevert();
        pollContract.usePoll(POLL_INDEX, POLL_OPTION_SELECTED);
        vm.stopPrank();
    }

    function testPoll_PreviouslyEnded() public MakePoll ClosePoll {
        vm.startPrank(CREATOR);
        vm.expectRevert("Poll already ended");
        pollContract.endPoll(POLL_INDEX);
        vm.stopPrank();
    }

    function testUse_Poll() public MakePoll UsePoll {
        uint256 currentValue_Of_option = pollContract
            .getSinglePoll(POLL_INDEX)
            .values[POLL_OPTION_SELECTED];
        vm.startPrank(USER1);

        assertEq(currentValue_Of_option, 1);
        assertEq(pollContract.alreadyParticipated(POLL_INDEX), true);
    }

    // function testOnlyOwner() public MakePoll UsePoll {
    //     vm.expectRevert("Not the poll owner");
    //     pollContract.deletePoll(POLL_INDEX);
    // }

    function testDelete_Poll() public MakePoll UsePoll {
        vm.startPrank(CREATOR);
        pollContract.deletePoll(POLL_INDEX);
    }

    function testCan_Participate() public MakePoll {
        vm.startPrank(USER1);
        assertEq(pollContract.canParticipate(1), true);
    }

    function testEnd_Poll() public MakePoll UsePoll ClosePoll {
        vm.startPrank(CREATOR);
        pollContract.endPoll(POLL_INDEX);
    }

    // function testCreatePoll_Public_Access() public MakePoll_Public_Access {
    //     vm.startPrank(CREATOR);
    //     // assertEq(pollContract.getSinglePoll(1).length, 0);
    // }
}
