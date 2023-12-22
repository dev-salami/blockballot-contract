// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/**
 * @title PollContract
 *  @author Salami Khalil
 * @dev A smart contract for creating and managing polls.
 */
contract PollContract {
    // uint256 public POLL_UUID;

    struct Poll {
        bool ended;
        bool public__access;
        address Creator;
        string question;
        string[] options;
        uint256[] values;
        string poll_UUID;
    }

    mapping(address => string[]) private UserPolls;
    mapping(string => Poll) public Poll_List;
    mapping(string => mapping(address => bool)) private s_HasVoted; //Poll_Participant;
    mapping(string => mapping(address => bool)) private s_IsWhitelisted; // Poll_allowance

    error Not_Whitelisted();
    error Already_Voted();
    error Not_Owner();
    error Poll_Closed();

    event PollCreated(address indexed creator, string Poll_ID);
    event PollVoted(address indexed User, string Poll_ID);
    event PollDeleted(string indexed Poll_ID);
    event PollEnded(string indexed Poll_ID);

    /**
     * @dev Modifier to check if the caller is the owner of a poll.
     * @param _Id The ID of the poll.
     */
    modifier onlyOwner(string memory _Id) {
        require(msg.sender == Poll_List[_Id].Creator, "Not the poll owner");
        _;
    }

    /**
     * @dev Modifier to check if the Id is a valid ID.
     * @param _Id The ID of the poll.
     */
    modifier valid_ID(string memory _Id) {
        require(Poll_List[_Id].Creator != address(0), "Invalid ID");
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
        string memory UUID,
        bool _public__access,
        address[] memory _whiteList,
        string memory _question,
        string[] memory _options
    ) external {
        Poll memory polldata = Poll({
            ended: false,
            public__access: _public__access,
            Creator: msg.sender,
            question: _question,
            options: _options,
            values: new uint256[](_options.length),
            poll_UUID: UUID
        });

        if (!_public__access) {
            for (uint256 i = 0; i < _whiteList.length; ++i) {
                s_IsWhitelisted[UUID][_whiteList[i]] = true;
            }
        }

        Poll_List[UUID] = polldata;
        UserPolls[msg.sender].push(UUID);

        emit PollCreated(msg.sender, UUID);
    }

    function addAddress_to_whiteList(string memory _Id, address[] memory addresses)
        external
        onlyOwner(_Id)
        valid_ID(_Id)
    {
        if (Poll_List[_Id].public__access) {
            revert("Poll is publicly acessible");
        } else {
            for (uint256 i = 0; i < addresses.length; ++i) {
                s_IsWhitelisted[_Id][addresses[i]] = true;
            }
        }
    }

    /**
     * @dev Records a vote in a poll.
     * @param _Id The ID of the poll.
     * @param _optionIndex The index of the chosen option.
     */
    function usePoll(string calldata _Id, uint256 _optionIndex) external valid_ID(_Id) {
        if (Poll_List[_Id].ended) {
            revert Poll_Closed();
        }
        require(msg.sender != Poll_List[_Id].Creator, "Creator cannot participate");
        if (s_HasVoted[_Id][msg.sender]) {
            revert Already_Voted();
        }

        if (!Poll_List[_Id].public__access && !s_IsWhitelisted[_Id][msg.sender]) {
            revert Not_Whitelisted();
        }

        s_HasVoted[_Id][msg.sender] = true;
        Poll_List[_Id].values[_optionIndex] += 1;
        emit PollVoted(msg.sender, _Id);
    }

    /**
     * @dev Deletes a poll.
     * @param _Id The ID of the poll to be deleted.
     */
    function deletePoll(string memory _Id, uint256 _index) external valid_ID(_Id) onlyOwner(_Id) {
        delete Poll_List[_Id];
        UserPolls[msg.sender][_index] = UserPolls[msg.sender][UserPolls[msg.sender].length - 1];
        UserPolls[msg.sender].pop();
        emit PollDeleted(_Id);
    }

    /**
     * //  * @dev Ends a poll.
     * @param _Id The ID of the poll to be ended.
     */
    function endPoll(string calldata _Id) external valid_ID(_Id) onlyOwner(_Id) {
        require(!Poll_List[_Id].ended, "Poll already ended");
        Poll_List[_Id].ended = true;
        emit PollEnded(_Id);
    }

    /**
     * @dev Checks if an address can participate in a specific poll.
     * @param Poll_Id The ID of the poll.
     * @return It returns false if user has voted or if user is not whitelisted when poll public access is false else it returns true
     */
    function canParticipate(string calldata Poll_Id) external view valid_ID(Poll_Id) returns (bool) {
        // Checks if an address can participate in a specific poll.
        //It returns false if user has voted or  if user is not whitelisted when poll public access is false
        if (
            s_HasVoted[Poll_Id][msg.sender]
                || (!s_IsWhitelisted[Poll_Id][msg.sender] && !Poll_List[Poll_Id].public__access)
        ) return false;
        else return true;
    }

    /**
     * @dev Checks if an address has already participated in a specific poll.
     * @param Poll_Id The ID of the poll.
     * @return Whether the address has already participated.
     */
    function alreadyParticipated(string calldata Poll_Id) external view valid_ID(Poll_Id) returns (bool) {
        return s_HasVoted[Poll_Id][msg.sender];
    }

    /**
     * @dev Gets the IDs of polls created by the caller.
     * @return An array of poll IDs.
     */
    function getUserPolls() external view returns (string[] memory) {
        return UserPolls[msg.sender];
    }

    /**
     * @dev Gets the details of a specific poll.
     * @param Poll_Id The ID of the poll.
     * @return Poll details.
     */
    function getSinglePoll(string calldata Poll_Id) external view valid_ID(Poll_Id) returns (Poll memory) {
        return Poll_List[Poll_Id];
    }
}
