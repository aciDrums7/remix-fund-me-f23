//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    error NotOnwer();
    error NotEnoughFunds();
    error WithdrawFailed();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOnwer();
        }
        _;
    }

    address private immutable owner;

    uint256 public immutable i_minimumAmountInUsd;

    address[] funders;
    mapping(address funder => uint256 amountFunded) funderToAmountFunded;

    constructor(uint256 _minimumAmountInUsd) {
        owner = msg.sender;
        i_minimumAmountInUsd = _minimumAmountInUsd;
    }

    function fund() public payable {
        if (msg.value.fromEthToUsd() < i_minimumAmountInUsd) {
            revert NotEnoughFunds();
        }
        funders.push(msg.sender);
        funderToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() external onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            funderToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool isSent, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!isSent) {
            revert WithdrawFailed();
        }
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
