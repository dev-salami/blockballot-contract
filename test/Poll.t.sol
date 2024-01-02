// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {DeployPoll} from "../script/Poll.s.sol";
import {PollContract} from "../src/Poll.sol";

contract PollTest is Test {
    PollContract pollContract;
    address constant CREATOR = address(1);
    address constant USER1 = address(2);
    address constant USER2 = address(3);
    address constant USER5 = address(5);
    address constant USER6 = address(6);

    string constant UUID = "5fa51ced-58c1-4af1-bc60-63bb4f792ec4";
    string constant FAKE_UUID = "63bb4fe7-bc60-5afd-ef94-37dd2r212et5";

    bool constant PUBLIC_ACCESS = false;
    bool constant PUBLIC_ACCESS_TRUE = true;
    uint256 constant POLL_OPTION_SELECTED = 1;
    uint256 constant POLL_INDEX = 1;

    address[] WHITELIST = [USER1, USER2];
    address[] More_WHITELIST = [USER5, USER6];

    string constant QUESTION = "Who are you ?";
    string[] OPTIONS = ["Ade", "Bola", "Titi"];

    modifier MakePoll() {
        vm.startPrank(CREATOR);
        pollContract.createPoll(
            UUID,
            PUBLIC_ACCESS,
            WHITELIST,
            QUESTION,
            OPTIONS
        );
        vm.stopPrank();
        _;
    }

    modifier UsePoll() {
        vm.startPrank(USER1);
        pollContract.usePoll(UUID, POLL_OPTION_SELECTED);
        vm.stopPrank();
        _;
    }

    modifier ClosePoll() {
        vm.startPrank(CREATOR);
        pollContract.endPoll(UUID);
        vm.stopPrank();
        _;
    }

    modifier MakePoll_Public_Access() {
        vm.startPrank(CREATOR);
        pollContract.createPoll(
            UUID,
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
        console.log(pollContract.getSinglePoll(UUID).Creator);
        assertEq(pollContract.getSinglePoll(UUID).Creator, CREATOR);
        assertEq(pollContract.getUserPolls().length, 1);
        assertEq(pollContract.getSinglePoll(UUID).poll_UUID, UUID);
        // vm.expectEmit();
    }

    function testPoll_Creator_Cannot_Partake() public MakePoll {
        vm.startPrank(CREATOR);
        vm.expectRevert("Creator cannot participate");
        pollContract.usePoll(UUID, POLL_OPTION_SELECTED);
    }

    function testPoll_Invalid_Id() public MakePoll {
        vm.expectRevert();
        vm.startPrank(USER1);
        pollContract.usePoll(FAKE_UUID, POLL_OPTION_SELECTED);
        vm.stopPrank();
    }

    function testPoll_AlreadyVoted() public MakePoll UsePoll {
        vm.startPrank(USER1);
        vm.expectRevert();
        pollContract.usePoll(UUID, POLL_OPTION_SELECTED);
    }

    function testPoll_NotWhiteListed() public MakePoll {
        vm.startPrank(address(9));
        vm.expectRevert();
        pollContract.usePoll(UUID, POLL_OPTION_SELECTED);
    }

    function testPoll_Closed() public MakePoll ClosePoll {
        vm.startPrank(USER1);
        vm.expectRevert();
        pollContract.usePoll(UUID, POLL_OPTION_SELECTED);
        vm.stopPrank();
    }

    function testPoll_PreviouslyEnded() public MakePoll ClosePoll {
        vm.startPrank(CREATOR);
        vm.expectRevert("Poll already ended");
        pollContract.endPoll(UUID);
        vm.stopPrank();
    }

    function testUse_Poll() public MakePoll UsePoll {
        uint256 currentValue_Of_option = pollContract
            .getSinglePoll(UUID)
            .values[POLL_OPTION_SELECTED];
        vm.startPrank(USER1);

        assertEq(currentValue_Of_option, 1);
        assertEq(pollContract.alreadyParticipated(UUID), true);
    }

    function testAddressToWhitelist_fail() public MakePoll_Public_Access {
        vm.startPrank(CREATOR);

        vm.expectRevert("Poll is publicly acessible");
        pollContract.addAddressToWhiteList(UUID, More_WHITELIST);
    }

    function testAddressToWhitelist() public MakePoll {
        vm.startPrank(CREATOR);

        pollContract.addAddressToWhiteList(UUID, More_WHITELIST);
    }

    function testDelete_Poll() public MakePoll UsePoll {
        vm.startPrank(CREATOR);
        pollContract.deletePoll(UUID, 0);
    }

    function testCan_Participate() public MakePoll {
        vm.startPrank(USER1);
        assertEq(pollContract.canParticipate(UUID), true);
    }

    function testEnd_Poll() public MakePoll UsePoll ClosePoll {
        vm.startPrank(CREATOR);
        vm.expectRevert("Poll already ended");
        pollContract.endPoll(UUID);
    }

    // function testcreatePoll_Public_Access() public MakePoll_Public_Access {
    //     vm.startPrank(CREATOR);
    //     // assertEq(pollContract.getSinglePoll(1).length, 0);
    // }
}
