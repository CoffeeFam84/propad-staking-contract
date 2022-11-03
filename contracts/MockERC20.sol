// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor () ERC20 ("PROPAD", "PPAD") {
      _mint(msg.sender, 1000000000000 * 10 ** 18);
  }
}