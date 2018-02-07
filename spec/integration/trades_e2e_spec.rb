require 'spec_helper'
require 'exchange_rate_fetcher'

describe 'Trades E2E' do
  let(:exchange_rate_fetcher) { ExchangeRateFetcher.new }

  it 'generates tax report for simple stock sell' do
    tax_records = tax_report(read_fixture('stock_sell.xml'))

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('EWZ: ISHARES MSCI BRAZIL CAPPED E')
    expect(tax_records[0][1]).to eq('aktsia')
    expect(tax_records[0][2]).to eq(60)
    expect(tax_records[0][3]).to eq('2017-08-01')
    expect(tax_records[0][4]).to eq('US')
    expect(tax_records[0][5]).to eq('1822.19')
    expect(tax_records[0][6]).to eq('0.28')
    expect(tax_records[0][7]).to eq('1895.20')
  end

  def tax_report(data)
    trades = IbEstonia::Trades::Importer.import(data, exchange_rate_fetcher)
    records = IbEstonia::Trades::TaxReport.new(trades).generate_tax_records
    IbEstonia::Trades::EmtaFormatter.format(records)
  end
end
