//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    AggregatorV3Interface constant priceFeed =
        AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

    function getVersion() internal view returns (uint256) {
        return priceFeed.version();
    }

    function getDecimals() internal view returns (uint8) {
        return priceFeed.decimals();
    }

    function getDescription() internal view returns (string memory) {
        return priceFeed.description();
    }

    function getPrice() internal view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function fromEthToUsd(uint256 _ethAmount) internal view returns (uint256) {
        uint256 ethPriceInUsd = uint256(getPrice());
        if (getDecimals() == 8) {
            ethPriceInUsd *= 1e10;
        }
        return (ethPriceInUsd * _ethAmount) / 1e36;
    }
}
