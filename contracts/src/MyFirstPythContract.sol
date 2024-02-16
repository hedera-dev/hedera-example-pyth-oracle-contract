// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

contract MyFirstPythContract {
  IPyth pyth;
  bytes32 hbarUsdPriceId;

  constructor(address _pyth, bytes32 _hbarUsdPriceId) {
    pyth = IPyth(_pyth);
    hbarUsdPriceId = _hbarUsdPriceId;
  }

  function mint() public payable {
    PythStructs.Price memory price = pyth.getPrice(hbarUsdPriceId);

    uint hbarPrice8Decimals = (uint(uint64(price.price)) * (10 ** 8)) /
      (10 ** uint8(uint32(-1 * price.expo)));
    uint oneDollarInHbar = ((10 ** 8) * (10 ** 8)) / hbarPrice8Decimals;

    if (msg.value >= oneDollarInHbar) {
      // User paid enough money.
      // TODO: mint the NFT here
    } else {
      revert InsufficientFee();
    }
  }

  function updateAndMint(bytes[] calldata pythPriceUpdate) external payable {
    uint updateFee = pyth.getUpdateFee(pythPriceUpdate);
    pyth.updatePriceFeeds{ value: updateFee }(pythPriceUpdate);

    mint();
  }

  function getPyth() public view returns (address) {
      return address(pyth);
  }

  function getHbarUsdPriceId() public view returns (bytes32) {
      return hbarUsdPriceId;
  }

  // Error raised if the payment is not sufficient
  error InsufficientFee();
}
