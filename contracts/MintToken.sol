// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintToken is ERC20("Mint Token", "MTS") {

    constructor(address _owner) public {
        _setupDecimals(18);
        _mint(_owner, 1e27);
    }

}