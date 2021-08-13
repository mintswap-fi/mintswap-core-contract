// SPDX-License-Identifier: MIT

// P1 - P3: OK
pragma solidity 0.6.12;

import "./libraries/SafeMath.sol";
import "./libraries/SafeERC20.sol";

import "./OwnableContract.sol";

// Distribution fee
contract MintRewordDistribution is OwnableContract {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // MTS token
    address public mts;
    // Development team reword address
    address public devTo;
    // MintBar address
    address public bar;

    address private deadAddress = 0x000000000000000000000000000000000000dEaD;

    // Allocation points assigned to MintBar
    uint256 public barAllocPoint = 10;
    // Allocation points assigned to development team 
    uint256 public devAllocPoint = 3;
    // Allocation points assigned to deflation mts
    uint256 public deflationAllocPoint = 7; 
    // Total allocation points. Must be the sum of all allocation points.
    uint256 public totalAllocPoint = 0; 

    event Distribution(
        address indexed bar,
        address indexed devTo,
        uint256 amountBar,
        uint256 amountDev,
        uint256 amountDeflation
    );
    event BarAllocPoint(address indexed sender, uint256 allocPoint);
    event DevAllocPoint(address indexed sender, uint256 allocPoint);
    event DeflationAllocPoint(address indexed sender, uint256 allocPoint);

    constructor(address _bar, address _mts, address _devTo) public {
        bar = _bar;
        mts = _mts;
        devTo = _devTo;

        totalAllocPoint = barAllocPoint.add(devAllocPoint).add(deflationAllocPoint);
    }

    // distribute reword
    function distribute() external onlyAdmin() {
        uint256 totalAmount = IERC20(mts).balanceOf(address(this));
        if (totalAmount < 10) {
            return;
        }

        // distribute to MintBar
        uint256 amountBar = totalAmount.mul(barAllocPoint).div(totalAllocPoint);
        IERC20(mts).safeTransfer(bar, amountBar);
        // distribute to dev
        uint256 amountDev = totalAmount.mul(devAllocPoint).div(totalAllocPoint);
        IERC20(mts).safeTransfer(devTo, amountDev);
        // distribute to deflation
        uint256 amountDeflation = totalAmount.mul(deflationAllocPoint).div(totalAllocPoint);
        IERC20(mts).safeTransfer(deadAddress, amountDeflation);

        emit Distribution(bar, devTo, amountBar, amountDev, amountDeflation);
    }

    function setDevTo(address _devTo) public onlyOwner {
        devTo = _devTo;
    }

    function setBar(address _bar) public onlyOwner {
        bar = _bar;
    }

    function setBarAllocPoint(uint256 _barAllocPoint) public onlyOwner {
        barAllocPoint = _barAllocPoint;
        totalAllocPoint = barAllocPoint.add(devAllocPoint).add(deflationAllocPoint);
        emit BarAllocPoint(msg.sender, barAllocPoint);
    }

    function setDevAllocPoint(uint256 _devAllocPoint) public onlyOwner {
        devAllocPoint = _devAllocPoint;
        totalAllocPoint = barAllocPoint.add(devAllocPoint).add(deflationAllocPoint);
        emit DevAllocPoint(msg.sender, devAllocPoint);
    }

    function setDeflationAllocPoint(uint256 _deflationAllocPoint) public onlyOwner {
        deflationAllocPoint = _deflationAllocPoint;
        totalAllocPoint = barAllocPoint.add(devAllocPoint).add(deflationAllocPoint);
        emit DeflationAllocPoint(msg.sender, deflationAllocPoint);
    }

}
