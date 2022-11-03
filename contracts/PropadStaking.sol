//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPROPAD {
  function balanceOf(address _user) external view returns(uint256);
  function transferFrom(address _user1, address _user2, uint256 _amount) external;
  function transfer(address _user, uint256 _amount) external;  
}

contract Staking {

  struct STAKE_INFO {
    uint256 tier;
    uint256 end_time;
    uint256 amount;
  }

  address public POOL_WALLET = 0xBBC6232725EAf504c53A09cFf63b1186BCAc6316;

  IPROPAD propad;
  mapping(address => STAKE_INFO) stakes;
  uint256[] MIN_AMOUNTS = [1000, 2000, 3000];
  uint256[] LOCK_PERIODS = [5 minutes, 10 minutes, 30 minutes];
  uint256[] REWARD_PERCENT = [20, 30, 50];

  uint256 totalTokenStaked;
  uint256 totalStakers;

  constructor ( address _propad ) {
    propad = IPROPAD(_propad);
  }

  function stake(uint256 _tier, uint256 _amount) external {
    require(propad.balanceOf(msg.sender) > _amount, "not enough token");
    require(stakes[msg.sender].amount == 0, "You already have active staking");
    require(_amount >= MIN_AMOUNTS[_tier], "not enough amount for this tier");
    propad.transferFrom(msg.sender, address(this), _amount);
    stakes[msg.sender].amount += _amount;
    stakes[msg.sender].end_time = block.timestamp + LOCK_PERIODS[_tier];
    totalStakers ++;
    totalTokenStaked += _amount;
  }

  function withdraw() external {
    STAKE_INFO storage _info = stakes[msg.sender];
    require(_info.amount > 0, "CrocosFarm: Unable to withdraw Ft");
    require(_info.end_time <= block.timestamp, "You can't withdraw during lock period.");
    uint256 reward = propad.balanceOf(address(this)) * REWARD_PERCENT[_info.tier] / 100;
    propad.transferFrom(POOL_WALLET, msg.sender, reward);
    _info.amount = 0;
    totalStakers --;
    totalTokenStaked -= _info.amount;
  }

  function setPoolWallet(address _pool) external {
    POOL_WALLET = _pool;
  }

  function setTokenAddress(address _token) external {
    propad = IPROPAD(_token);
  }

  function getPoolInfo() external view returns (uint256, uint256, uint256) {
    return (totalTokenStaked, totalStakers, propad.balanceOf(address(this)));
  }

  function getStakerInfo(address _staker) external view returns (uint256, uint256, uint256, uint256) {
    STAKE_INFO storage _info = stakes[_staker];
    uint256 reward = 0;
    if (_info.amount > 0 && _info.end_time < block.timestamp) {
      reward = propad.balanceOf(address(this)) * REWARD_PERCENT[_info.tier] / 100;
    }
    return (_info.tier, _info.amount, _info.end_time, reward);
  }
}
