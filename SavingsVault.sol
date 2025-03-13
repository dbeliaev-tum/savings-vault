// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SavingsVault
 * @dev A decentralized savings vault that allows users to deposit funds with a lock period.
 * Users can withdraw their funds only after the lock time has expired.
 * The contract owner does not have access to user funds.
 */
contract SavingsVault is Ownable {
    /**
     * @dev Structure representing a user's deposit.
     * @param amount The amount of Ether deposited.
     * @param unlockTime The timestamp when the funds will become available for withdrawal.
     */
    struct Deposit {
        uint256 amount;
        uint256 unlockTime;
    }

    /// @dev Mapping from user address to their list of deposits.
    mapping(address => Deposit[]) private userDeposits;

    /// @notice Emitted when a user makes a deposit.
    /// @param user The address of the depositor.
    /// @param amount The amount of Ether deposited.
    /// @param unlockTime The timestamp when the deposit will be unlocked.
    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);

    /// @notice Emitted when a user successfully withdraws their funds.
    /// @param user The address of the withdrawer.
    /// @param amount The total amount withdrawn.
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Contract constructor that initializes the owner.
     * @param initialOwner The address of the contract owner.
     */
    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Allows a user to deposit Ether into the vault with a lock time.
     * @dev The deposit is added to the user's deposit list with a specific unlock time.
     * @param _lockTime The duration (in seconds) for which the funds should be locked.
     */
    function deposit(uint256 _lockTime) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_lockTime > 0, "Lock time must be greater than 0");

        uint256 unlockTime = block.timestamp + _lockTime;
        userDeposits[msg.sender].push(Deposit({ amount: msg.value, unlockTime: unlockTime }));

        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    /**
     * @notice Retrieves the list of deposits for the calling user.
     * @return amounts An array of deposit amounts.
     * @return timeLeft An array of remaining lock durations for each deposit.
     */
    function getMyDeposits() external view returns (uint256[] memory amounts, uint256[] memory timeLeft) {
        Deposit[] storage deposits = userDeposits[msg.sender];
        uint256 count = deposits.length;

        amounts = new uint256[](count);
        timeLeft = new uint256[](count);
        uint256 currentTimestamp = block.timestamp;

        for (uint256 i; i < count; ++i) {
            amounts[i] = deposits[i].amount;
            timeLeft[i] = deposits[i].unlockTime > currentTimestamp ? deposits[i].unlockTime - currentTimestamp : 0;
        }
    }

    /**
     * @notice Withdraws all unlocked deposits for the calling user.
     * @dev Iterates through the user's deposits, removing and summing up those that are unlocked.
     * Emits a {Withdrawn} event if successful.
     */
    function withdraw() external {
        Deposit[] storage deposits = userDeposits[msg.sender];
        uint256 totalAmount;
        uint256 length = deposits.length;
        uint256 i;

        while (i < length) {
            if (deposits[i].unlockTime <= block.timestamp) {
                totalAmount += deposits[i].amount;
                deposits[i] = deposits[length - 1]; // Replace with last element
                deposits.pop();
                length--;
            } else {
                ++i;
            }
        }

        require(totalAmount > 0, "No available funds to withdraw");

        (bool success, ) = payable(msg.sender).call{value: totalAmount}("");
        require(success, "Withdraw failed");

        emit Withdrawn(msg.sender, totalAmount);
    }

    /**
     * @notice Gets the total locked balance for the calling user.
     * @return lockedBalance The total amount of locked Ether.
     */
    function getLockedBalance() external view returns (uint256 lockedBalance) {
        Deposit[] storage deposits = userDeposits[msg.sender];
        uint256 length = deposits.length;
        uint256 currentTimestamp = block.timestamp;

        for (uint256 i; i < length; ++i) {
            if (deposits[i].unlockTime > currentTimestamp) {
                lockedBalance += deposits[i].amount;
            }
        }
    }
}
