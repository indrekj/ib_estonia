# IbEstonia

IbEstonia is a converter which takes trade data from Interactive Brokers as an input and creates a tax report which can be easily submitted to Estonian Tax and Customs Board.

It currently supports stocks, options & dividends. See *Limitations* section for known issues.

**NB**: This project currently is **experimental**. It is not meant for production use yet.

## Requirements

* Ruby 2.0+
* Node 8.0+

## Usage

### Download Trades & Dividends data

1. Open Interactive Brokers Account Management
2. Go to Reports -> Flex Queries
3. Create a new Custom Flex Query for each year **since account inception**
    1. Query Name: ib-$YEAR
    2. Date Period: Custom Date Range
    3. From Date: Beginning of $YEAR
    4. To Date: End of $YEAR
    5. Select "Trades", include all fields from "Executions"
    6. Select "Cash Transactions", include all fields from "Dividends" and "Withholding Tax"
    7. Select "Financial Instrument Information", include all fields.
4. Execute and download all exports

### Start ISIN provider

Interactive Brokers flex queries do not provide ISIN numbers for all securities. These however are needed for the dividends report. Stocks & options report has a country field which is also inferred from ISIN number. If you don't care about these limitions (e.g. you fill them manually) then skip this part.

1. Start your Trader Workstation
2. Open Edit -> Global Configuration -> Api -> Settings
3. Check "Enable ActiveX and Socket Clients" (feel free to keep it in Read-Only mode)
4. Save
5. Run `./start_isin_provider`

### Create report

Create a report using the confirmation data. For example, if you have data for 2015-2017 then run:
```sh
./start ib-2015.xml ib-2016.xml ib-2017.xml
```

## Limitations

* Long positions that have changed to a short position or vice versa are not displayed correctly (e.g. BUY 10 $RP, SELL 20 $RP). However closing a position and opening a new works correctly (e.g. BUY 10 $RP, SELL 10 $RP, SELL 10 $RP).
* Stock splits are not supported
* Option premiums are not included in the stock price
* Unknown: fractional shares may not work
* Unknown: one company acquiring another for money may not work
* Unknown: one company acquiring another for shares may not work
* Dividends: We use dividend report date for both report and tax withheld dates. This might not always be correct.
