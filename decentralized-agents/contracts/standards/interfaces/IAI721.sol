// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./IBase.sol";

/**
 * @title IAI721 Interface
 * @author ETERNAL AI
 * @notice This interface defines the standard for AI721, a protocol for decentralized inference
 *         that builds upon ERC721 to manage agent instances as a collection of NFTs.
 * @dev Designed to enable on-chain inference services where each agent is represented,
 *      identified, and managed via NFT-like tokens, ensuring ownership, transferability,
 *      and provenance. This protocol extends ERC721 conventions to support AI agents with
 *      specialized functionalities.
 */
interface IAI721 {
    /// @dev usageFee: The usage fee required to invoke this agent's functionalities.
    /// @dev isUsed: Signals whether this agent is actively engaged or in use.
    /// @dev modelId: Identifies the specific model from the associated model collection utilized by this agent.
    /// @dev promptScheduler: The address of promptScheduler contract.
    /// @dev sysPrompts: The system prompt data of this agent, mapped from string keys to arrays of prompt data, managed by the agent's owner.
    struct AgentConfig {
        uint128 usageFee;
        bool isUsed;
        uint32 modelId;
        address promptScheduler;
        mapping(string => bytes[]) sysPrompts;
    }

    /**
     * @dev Emitted when the GPU manager is updated.
     * @param gpuManager The address of the new GPU manager.
     */
    event GPUManagerUpdate(address gpuManager);

    /**
     * @dev Emitted when a new agent is minted.
     * @param agentId The ID of the newly minted agent.
     * @param uri The URI of the agent.
     * @param sysPrompt The system prompt associated with the agent.
     * @param fee The fee paid for the agent.
     * @param owner The address of the owner.
     */
    event NewAgent(
        uint256 indexed agentId,
        string uri,
        bytes sysPrompt,
        uint fee,
        address indexed owner
    );

    /**
     * @dev Emitted when the URI of an agent is updated.
     * @param agentId The ID of the agent.
     * @param uri The new URI of the agent.
     */
    event AgentURIUpdate(uint256 indexed agentId, string uri);

    /**
     * @dev Emitted when the data of an agent is updated.
     * @param agentId The ID of the agent.
     * @param promptIndex The index of the prompt being updated.
     * @param oldSysPrompt The old system prompt data.
     * @param newSysPrompt The new system prompt data.
     */
    event AgentDataUpdate(
        uint256 indexed agentId,
        uint256 promptIndex,
        bytes oldSysPrompt,
        bytes newSysPrompt
    );

    /**
     * @dev Emitted when new data is added to an agent.
     * @param agentId The ID of the agent.
     * @param sysPrompt The new system prompt data.
     */
    event AgentDataAddNew(uint256 indexed agentId, bytes[] sysPrompt);

    /**
     * @dev Emitted when the usage fee of an agent is updated.
     * @param agentId The ID of the agent.
     * @param fee The new usage fee of the agent.
     */
    event AgentUsageFeeUpdate(uint256 indexed agentId, uint fee);

    /**
     * @dev Emitted when the model ID of an agent is updated.
     * @param agentId The ID of the agent whose model ID is being updated.
     * @param oldModelId The previous model ID of the agent.
     * @param newModelId The new model ID of the agent.
     */
    event AgentModelIdUpdate(
        uint256 indexed agentId,
        uint256 oldModelId,
        uint256 newModelId
    );

    /**
     * @dev Emitted when the prompt scheduler of an agent is updated.
     * @param agentId The ID of the agent whose prompt scheduler is being updated.
     * @param oldPromptScheduler The previous address of the prompt scheduler.
     * @param newOldPromptScheduler The new address of the prompt scheduler.
     */
    event AgentPromptSchedulerUpdate(
        uint256 indexed agentId,
        address oldPromptScheduler,
        address newOldPromptScheduler
    );

    /**
     * @dev Emitted when an inference is performed.
     * @param agentId The ID of the agent associated with the inference.
     * @param caller The address of the caller.
     * @param data The data related to the inference.
     * @param fee The usage fee paid for using agent.
     * @param externalData External data related to the inference.
     * @param inferenceId The ID of the inference.
     */
    event InferencePerformed(
        uint256 indexed agentId,
        address indexed caller,
        bytes data,
        uint fee,
        string externalData,
        uint256 inferenceId
    );

    /**
     * @dev Error thrown when an invalid agent ID is provided.
     */
    error InvalidAgentId();

    /**
     * @dev Error thrown when an invalid agent fee is provided.
     */
    error InvalidAgentFee();

    /**
     * @dev Error thrown when invalid agent data is provided.
     */
    error InvalidAgentData();

    /**
     * @dev Error thrown when an invalid agent prompt index is provided.
     */
    error InvalidAgentPromptIndex();

    /**
     * @dev Error thrown when the caller is not authorized.
     */
    error Unauthorized();

    /**
     * @dev Error thrown when invalid data is provided.
     */
    error InvalidData();

    /**
     * @dev Error thrown when invalid next agent id is provided.
     */
    error InvalidNextAgentId();

    /**
     * @dev Returns the address of the GPU manager.
     * @return The address of the GPU manager.
     */
    function getGPUManager() external view returns (address);

    /**
     * @dev Returns the address of the token used to pay the inference fee.
     * @return The address of the token fee.
     */
    function getTokenFee() external view returns (address);

    /**
     * @dev Returns the next agent ID.
     * @return nextAgentId The next agent ID.
     */
    function nextAgentId() external view returns (uint256 nextAgentId);

    /**
     * @dev Returns an array of agent IDs owned by a given owner.
     * @param owner The address of the owner.
     * @return An array of agent IDs.
     */
    function getAgentIdByOwner(
        address owner
    ) external view returns (uint256[] memory);

    /**
     * @dev Returns the using fee of a specific agent.
     * @param agentId The unique identifier of the agent.
     * @return The fee amount.
     */
    function getAgentUsageFee(uint256 agentId) external view returns (uint256);

    /**
     * @notice Retrieves the system prompt associated with a specific agent.
     * @param id The unique identifier of the agent.
     * @param promptKey The key corresponding to the desired prompt.
     * @return An array of bytes representing the system prompt.
     */
    function getAgentSystemPrompt(
        uint256 id,
        string calldata promptKey
    ) external view returns (bytes[] memory);

    /**
     * @notice Retrieves the metadata associated with a given agent ID.
     * @param agentId The unique identifier of the agent.
     * @return fee The using fee associated with the agent.
     * @return isUsed A boolean indicating whether the agent is currently in use.
     * @return modelId The model ID associated with the agent.
     * @return promptScheduler The address of the prompt scheduler for the agent.
     */
    function getAgentConfig(
        uint256 agentId
    )
        external
        view
        returns (
            uint128 fee,
            bool isUsed,
            uint32 modelId,
            address promptScheduler
        );

    /**
     * @dev Executes an inference request for a specified agent. This function facilitates the interaction with
     *      an AI agent by providing the necessary data and parameters to perform an inference operation.
     * @notice The `feeAmount` must be greater than or equal to the fee required to use the agent.
     * @param agentId The ID of the agent.
     * @param inferenceData The calldata for the inference.
     * @param externalData The external data for the inference.
     * @param promptKey The key of the prompt for the inference.
     * @param feeAmount The amount of fee to be paid for the inference.
     */
    function infer(
        uint256 agentId,
        bytes calldata inferenceData,
        string calldata externalData,
        string calldata promptKey,
        uint256 feeAmount
    ) external returns (uint256);

    /**
     * @dev Executes an inference request for a specified agent. This function facilitates the interaction with
     *      an AI agent by providing the necessary data and parameters to perform an inference operation.
     * @notice The `feeAmount` must be greater than or equal to the fee required to use the agent.
     * @param agentId The ID of the agent.
     * @param inferenceData The calldata for the inference.
     * @param externalData The external data for the inference.
     * @param promptKey The key of the prompt for the inference.
     * @param feeAmount The amount of fee to be paid for the inference.
     * @param rawFlag The flag to indicate the format of the calldata and the result of the inference.
     *                  If rawFlag is true, the calldata and inference result are in raw format.
     *                  If rawFlag is false, the calldata and inference result are in IPFS link format.
     */
    function infer(
        uint256 agentId,
        bytes calldata inferenceData,
        string calldata externalData,
        string calldata promptKey,
        bool rawFlag,
        uint256 feeAmount
    ) external returns (uint256);
}
