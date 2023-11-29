// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title PollContract
 @author Salami Khalil
 * @dev A smart contract for creating and managing polls.
 */
contract PollContract {
    uint256 public POLL_UUID;

    struct Poll {
        bool ended;
        bool public__access;
        uint256 Id;
        address Creator;
        string question;
        string[] options;
        uint256[] values;
    }

    mapping(address => uint256[]) private UserPolls;
    mapping(uint256 => Poll) private Poll_List;
    mapping(uint256 => mapping(address => bool)) private Poll_Participant;
    mapping(uint256 => mapping(address => bool)) private Poll_Allowance;

    error Not_Whitelisted();
    error Already_Voted();
    error Not_Owner();
    error Poll_Closed();

    event PollCreated(address indexed creator, uint256 Poll_ID);
    event PollVoted(address indexed User, uint256 Poll_ID);
    event PollDeleted(uint256 indexed Poll_ID);
    event PollEnded(uint256 indexed Poll_ID);

    /**
     * @dev Modifier to check if the caller is the owner of a poll.
     * @param _Id The ID of the poll.
     */
    modifier onlyOwner(uint256 _Id) {
        require(msg.sender == Poll_List[_Id].Creator, "Not the poll owner");
        _;
    }

    /**
     * @dev Modifier to check if the Id is a valid ID.
     * @param _Id The ID of the poll.
     */
    modifier valid_ID(uint256 _Id) {
        // require(Poll_List[_Id].Id != 0, "Invalid ID");
        _;
    }

    /**
     * @dev Creates a new poll.
     * @param _public__access Whether the poll is public or private.
     * @param _whiteList List of addresses allowed to participate (for private polls).
     * @param _question The poll question.
     * @param _options List of poll options.
     */
    function CreatePoll(
        bool _public__access,
        address[] memory _whiteList,
        string memory _question,
        string[] memory _options
    ) external {
        POLL_UUID += 1;
        Poll memory polldata = Poll({
            Id: POLL_UUID,
            ended: false,
            public__access: _public__access,
            Creator: msg.sender,
            question: _question,
            options: _options,
            values: new uint256[](_options.length)
        });

        if (!_public__access) {
            for (uint256 i = 0; i < _whiteList.length; ++i) {
                Poll_Allowance[POLL_UUID][_whiteList[i]] = true;
            }
        }

        Poll_List[POLL_UUID] = polldata;
        UserPolls[msg.sender].push(POLL_UUID);

        emit PollCreated(msg.sender, POLL_UUID);
    }

    /**
     * @dev Records a vote in a poll.
     * @param _Id The ID of the poll.
     * @param _optionIndex The index of the chosen option.
     */
    function usePoll(uint256 _Id, uint256 _optionIndex) external valid_ID(_Id) {
        if (Poll_List[_Id].ended) {
            revert Poll_Closed();
        }
        require(
            msg.sender != Poll_List[_Id].Creator,
            "Creator cannot participate"
        );
        if (Poll_Participant[_Id][msg.sender]) {
            revert Already_Voted();
        }

        if (
            !Poll_List[_Id].public__access && !Poll_Allowance[_Id][msg.sender]
        ) {
            revert Not_Whitelisted();
        }

        Poll_Participant[_Id][msg.sender] = true;
        Poll_List[_Id].values[_optionIndex] += 1;
        emit PollVoted(msg.sender, _Id);
    }

    /**
     * @dev Deletes a poll.
     * @param _Id The ID of the poll to be deleted.
     */
    function deletePoll(uint256 _Id) external valid_ID(_Id) onlyOwner(_Id) {
        delete Poll_List[_Id];
        emit PollDeleted(_Id);
    }

    /**
     * @dev Ends a poll.
     * @param _Id The ID of the poll to be ended.
     */
    function endPoll(uint256 _Id) external valid_ID(_Id) onlyOwner(_Id) {
        require(!Poll_List[_Id].ended, "Poll already ended");
        Poll_List[_Id].ended = true;
        emit PollEnded(_Id);
    }

    /**
     * @dev Checks if an address can participate in a specific poll.
     * @param Poll_Id The ID of the poll.
     * @return Whether the address can participate.
     */
    function canParticipate(
        uint256 Poll_Id
    ) external view valid_ID(Poll_Id) returns (bool) {
        return Poll_Participant[Poll_Id][msg.sender];
    }

    /**
     * @dev Checks if an address has already participated in a specific poll.
     * @param Poll_Id The ID of the poll.
     * @return Whether the address has already participated.
     */
    function alreadyParticipated(
        uint256 Poll_Id
    ) external view valid_ID(Poll_Id) returns (bool) {
        return Poll_Allowance[Poll_Id][msg.sender];
    }

    /**
     * @dev Gets the IDs of polls created by the caller.
     * @return An array of poll IDs.
     */
    function getUserPolls() external view returns (uint256[] memory) {
        return UserPolls[msg.sender];
    }

    /**
     * @dev Gets the details of a specific poll.
     * @param Poll_Id The ID of the poll.
     * @return Poll details.
     */
    function getSinglePoll(
        uint256 Poll_Id
    ) external view valid_ID(Poll_Id) returns (Poll memory) {
        return Poll_List[Poll_Id];
    }
}
