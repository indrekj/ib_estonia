# IbEstonia

IbEstonia is a converter which takes trade data from Interactive Brokers as an input and creates a tax report which can be easily submitted to Estonian Tax and Customs Board.

**NB**: This project currently is **experimental**. It is not meant for production use yet.

## Usage

### Download Trade Confirmation data

1. Open Interactive Brokers Account Management.
2. Go to Reports -> Trade Confirmations -> Flex Queries
3. Create a Flex Query for each year since inception
    1. Query Name: confirms-$YEAR
    2. From Date: Beginning of $YEAR
    3. To Date: End of $YEAR
    4. Level of Details: Select "Symbol Summary" & "Execution"
    5. Add all available fields to "Fields Included" list
4. Execute and download all exports

### Create report

Create a report using the confirmation data. For example, if you have data for 2015-2017 then run:
```sh
./start confirms-2015.xml confirms-2016.xml confirms-2017.xml
```

## Limitations

* Currently basic stock and option trades are supported
* Long positions that have changed to a short position or vice versa are not displayed correctly (e.g. BUY 10 $RP, SELL 20 $RP). However closing a position and opening a new works correctly (e.g. BUY 10 $RP, SELL 10 $RP, SELL 10 $RP).
* Stock splits are not supported
* Options exercising is not supported
