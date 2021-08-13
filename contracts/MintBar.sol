// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./Ownable.sol";

// MintBar is the coolest bar in town. You come in with some MTS, and leave with more! The longer you stay, the more MTS you get.
//
// This contract handles swapping to and from xMTS, MintSwap's staking token.
contract MintBar is ERC20("MintBar", "xMTS"), Ownable{
    using SafeMath for uint256;
    IERC20 public mts;

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant OFFSET19700101 = 2440588;

    // Enable to start days of month
    uint8 public startDayOfMonth = 1;
    // Enable to end days of month
    uint8 public endDayOfMonth = 3;
    // Enable to enter the bar
    bool public enterEnable = false;
    // Enable to leave the bar
    bool public leaveEnable = false;

    event EnterEnable(address indexed sender, bool status);
    event LeaveEnable(address indexed sender, bool status);
    event EnableDayOfMonth(address indexed sender, uint8 startDayOfMonth, uint8 endDayOfMonth);

    // Define the MTS token contract
    constructor(IERC20 _mts) public {
        mts = _mts;
    }

    // Enter the bar. Pay some MTSs. Earn some shares.
    // Locks MTS and mints xMTS
    function enter(uint256 _amount) public {
        require(_isEnableDayOfMonth() || enterEnable, "Can not enter now");

        // Gets the amount of MTS locked in the contract
        uint256 totalMts = mts.balanceOf(address(this));
        // Gets the amount of xMTS in existence
        uint256 totalShares = totalSupply();
        // If no xMTS exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalMts == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xMTS the MTS is worth. The ratio will change overtime, as xMTS is burned/minted and MTS deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalMts);
            _mint(msg.sender, what);
        }
        // Lock the MTS in the contract
        mts.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your MTSs.
    // Unlocks the staked + gained MTS and burns xMTS
    function leave(uint256 _share) public {
        require(_isEnableDayOfMonth() || leaveEnable, "Can not leave now");

        // Gets the amount of xMTS in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of MTS the xMTS is worth
        uint256 what = _share.mul(mts.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        mts.transfer(msg.sender, what);
    }

    // get ratio of xMTS to MTS (decimal is 6)
    function getRatio() public view returns (uint256 ratio) {
        // Gets the amount of xMTS in existence
        uint256 totalShares = totalSupply();
        if (totalShares == 0) {
            // If no xMTS exists, mint it 1:1 to the amount put in
            ratio = 1e6;
        } else {
            // Calculates the amount of MTS one xMTS is worth
            ratio = mts.balanceOf(address(this)).mul(1e6).div(totalShares);
        }
    }

    function _isEnableDayOfMonth() internal view returns (bool) {
        uint day = getDay(uint(now));
        if (day >= startDayOfMonth && day <= endDayOfMonth) {
            return true;
        } else {
            return false;
        }
    }

    function getDay(uint _timestamp) public pure returns (uint day) {
        uint __days = uint(_timestamp / SECONDS_PER_DAY);

        uint L = __days + 68569 + OFFSET19700101;
        uint N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        uint _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        uint _month = 80 * L / 2447;
        uint _day = L - 2447 * _month / 80;
        day = uint(_day);
    }

    // Set the bar status
    function setEnable(bool _enable) public onlyOwner {
        enterEnable = _enable;
        leaveEnable = _enable;
        emit EnterEnable(msg.sender, enterEnable);
        emit LeaveEnable(msg.sender, leaveEnable);
    }

    // Set enter the bar status
    function setEnterEnable(bool _enterEnable) public onlyOwner {
        enterEnable = _enterEnable;
        emit EnterEnable(msg.sender, enterEnable);
    }

    // Set leave the bar status
    function setLeaveEnable(bool _leaveEnable) public onlyOwner {
        leaveEnable = _leaveEnable;
        emit LeaveEnable(msg.sender, leaveEnable);
    }

    // Set the enable Days of month
    function setEnableDayOfMonth(uint8 _startDayOfMonth, uint8 _endDayOfMonth) public onlyOwner {
        require(_startDayOfMonth <= _endDayOfMonth, "_startDayOfMonth must less than or equal _endDayOfMonth");
        startDayOfMonth = _startDayOfMonth;
        endDayOfMonth = _endDayOfMonth;
        emit EnableDayOfMonth(msg.sender, startDayOfMonth, endDayOfMonth);
    }

}
