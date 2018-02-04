# IbEstonia

IbEstonia is a converter which takes trade data from Interactive Brokers as an input and creates a tax report which can be easily submitted to Estonian Tax and Customs Board.

It currently supports stocks, options & dividends. See *Limitations* section for known issues.

**NB**: This project currently is **experimental**. It is not meant for production use yet.

## Usage

### Download Trades & Dividends data

1. Open Interactive Brokers Account Management.
2. Go to Reports -> Flex Queries
3. Create a new Custom Flex Query for each year **since account inception**.
    1. Query Name: ib-$YEAR
    2. Date Period: Custom Date Range
    3. From Date: Beginning of $YEAR
    4. To Date: End of $YEAR
    5. Select "Trades", include all fields from "Executions"
    6. Select "Cash Transactions", include all fields from "Dividends" and "Withholding Tax"
    7. Select "Financial Instrument Information", include all fields.
4. Execute and download all exports

### Create report

Create a report using the confirmation data. For example, if you have data for 2015-2017 then run:
```sh
./start ib-2015.xml ib-2016.xml ib-2017.xml
```

## Limitations

* Country of Issue missing from all reports
* ISIN code missing from dividends report
* Long positions that have changed to a short position or vice versa are not displayed correctly (e.g. BUY 10 $RP, SELL 20 $RP). However closing a position and opening a new works correctly (e.g. BUY 10 $RP, SELL 10 $RP, SELL 10 $RP).
* Stock splits are not supported
* Option premiums are not included in the stock price
