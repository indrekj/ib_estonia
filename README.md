# IbEstonia

IbEstonia is a converter which takes trade data from Interactive Brokers as an input and creates a tax report which can be easily submitted to Estonian Tax and Customs Board.

**NB**: This project currently is **experimental**. It is not meant for production use yet.

## Usage

TODO

## Limitations

* Currently basic stock and option trades are supported
* Long positions that have changed to a short position or vice versa are not displayed correctly (e.g. BUY 10 $RP, SELL 20 $RP). However closing a position and opening a new works correctly (e.g. BUY 10 $RP, SELL 10 $RP, SELL 10 $RP).
* Stock splits are not supported
* Options exercising is not supported
