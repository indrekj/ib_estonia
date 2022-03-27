require 'spec_helper'
require 'exchange_rate_fetcher'

describe 'Trades E2E' do
  let(:exchange_rate_fetcher) { ExchangeRateFetcher.new }

  it 'generates tax report for simple stock sell' do
    tax_records = tax_report(read_fixture('stock_sell.xml'))

    expect(tax_records.count).to eq(1)
    expect(tax_records[0]).to eq([
      'US4642864007',
      'EWZ: ISHARES MSCI BRAZIL CAPPED E',
      'US',
      'aktsia',
      '01.08.2017',
      60,
      '1822.19',
      '0.28',
      '1895.19',
      0
    ])
  end

  def tax_report(data)
    isin_fetcher = double(fetch: 'US4642864007')
    symbols = IbEstonia::Symbols::Importer.import(data, isin_fetcher)
    trades = IbEstonia::Trades::Importer.import(data, symbols, exchange_rate_fetcher)
    records = IbEstonia::Trades::TaxReport.new(trades).generate_tax_records
    IbEstonia::Trades::EmtaFormatter.format(records)
  end
end
