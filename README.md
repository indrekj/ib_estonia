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
2. Go to Performance & Reports -> Flex Queries
3. Create a new Activity Flex Query:
    1. Query Name: ib-estonia-tax
    2. Select "Trades", include all fields from "Executions".
    3. Select "Cash Transactions", include all fields from "Dividends", "Withholding Tax" and "Detail".
    4. Select "Financial Instrument Information", include all fields.
4. Save changes
5. Run ib-estonia-tax query:
    1. Period: From the beginning of the year until the end of the year
    2. Run
5. Execute and download all exports
6. Rename ib-estonia-tax.xml to ib-$YEAR.xml

**Make sure you generate these XML files for each year since your account inception**.

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
./start ib-2016.xml ib-2017.xml ib-2018.xml ib-2019.xml ib-2020.xml ib-2021.xml
```

## Limitations

* Long positions that have changed to a short position or vice versa are not displayed correctly (e.g. BUY 10 $RP, SELL 20 $RP). However closing a position and opening a new works correctly (e.g. BUY 10 $RP, SELL 10 $RP, SELL 10 $RP).
* Stock splits are not supported
* Option premiums are not included in the stock price
* Dividends: We use dividend report date for both report and tax withheld dates. This might not always be correct, but I haven't seen it on different dates yet.
* Unknown: fractional shares may not work
* Unknown: one company acquiring another for money may not work
* Unknown: one company acquiring another for shares may not work
