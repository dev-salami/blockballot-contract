// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract PollContract {
    uint256 public POLL_UUID;

    struct Poll {
        bool ended;
        bool public__Poll;
        uint256 Id;
        address[] whiteList;
        address Creator;
        string question;
        string[] options;
        uint256[] values;
    }
    mapping(address => uint256[]) public UserPolls;
    mapping(uint256 => Poll) public Poll_List;

    mapping(uint256 => mapping(address => bool)) public Poll_Participant;
    mapping(uint256 => mapping(address => bool)) public Poll_Allowance;

    error NotAllowed(string description);
    error AlreadyVoted();
    error Not_Owner();
    error poll_Ended();

    event Poll_Created(address indexed creator, uint256 Poll_ID);
    event Vote_Poll(address indexed creator, uint256 Poll_ID);
    event Poll_Deleted(uint256 indexed Poll_ID);
    event Poll_Ended(uint256 indexed Poll_ID);

    modifier onlyOwner(uint256 Id) {
        if (msg.sender != Poll_List[Id].Creator) {
            revert Not_Owner();
        }
        _;
    }

    ///////////////////////////////////////////////////////////////
    ///////////////////////// FUNCTIONS //////////////////////////
    /////////////////////////////////////////////////////////////
    function CreatePoll(
        bool _public__Poll,
        address[] memory _whiteList,
        string memory _question,
        string[] memory _options
    ) public {
        Poll memory polldata = Poll({
            Id: POLL_UUID,
            ended: false,
            public__Poll: _public__Poll,
            whiteList: _whiteList,
            Creator: msg.sender,
            question: _question,
            options: _options,
            values: new uint256[](_options.length)
        });

        if (_public__Poll == false) {
            for (uint256 i = 0; i < _whiteList.length; ++i) {
                Poll_Allowance[POLL_UUID][_whiteList[i]] = true;
            }
        }
        Poll_List[POLL_UUID] = polldata;
        UserPolls[msg.sender].push(POLL_UUID);
        POLL_UUID += 1;
        emit Poll_Created(msg.sender, POLL_UUID);
    }

    function usePoll(address owner, uint256 Id, uint256 optionIndex) external {
        if (Poll_List[Id].ended == true) {
            revert poll_Ended();
        }
        require(
            msg.sender != Poll_List[Id].Creator,
            "Creator cannot participate"
        );
        if (Poll_Participant[Id][msg.sender] == true) {
            revert AlreadyVoted();
        }

        if (
            Poll_List[Id].public__Poll == false &&
            Poll_Allowance[Id][msg.sender] == false
        ) {
            revert NotAllowed("Your address is not on the whitelist");
        }

        Poll_Participant[Id][msg.sender] = true;
        Poll_List[Id].values[optionIndex] += 1;
        emit Vote_Poll(owner, Id);

        // address[] memory whiteList = Poll_List[poll_ID].whiteList;

        // for (uint256 i = 0; i < whiteList.length; ++i) {
        //     if (whiteList[i] == msg.sender) {
        //         uint256 Poll_Index = UserPolls[owner][poll_ID].Id;
        //         Poll_Participant[Poll_Index][msg.sender] = true;
        //         UserPolls[owner][poll_ID].values[optionIndex] += 1;
        //         emit Vote_Poll(owner, poll_ID);
        //     } else {
        //         revert NotAllowed("You address is not on the whiteList");
        //     }
        // }
    }

    function deletePoll(uint256 _Id) public onlyOwner(_Id) {
        // Poll memory temp_poll = poll_data[poll_data.length - 1];
        // Remove the last element
        delete Poll_List[_Id];
        emit Poll_Deleted(_Id);
    }

    function endPoll(uint256 _Id) public onlyOwner(_Id) {
        require(Poll_List[_Id].ended == false, "Poll alredy ended");
        Poll_List[_Id].ended = true;
        emit Poll_Ended(_Id);
    }

    ///////////////////////////////////////////////////////////////
    ///////////////////////// GETTER FUNCTIONS //////////////////////////
    /////////////////////////////////////////////////////////////
    // function getMyPolls() external view returns (uint256[] memory) {
    //     return UserPolls[msg.sender];
    // }
}
