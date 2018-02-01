require 'spec_helper'
require 'exchange_rate_fetcher'

describe 'E2E' do
  let(:exchange_rate_fetcher) { ExchangeRateFetcher.new }

  it 'generates tax report for simple stock sell' do
    tax_records = tax_report(read_fixture('stock_sell.xml'))

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('CRM: SALESFORCE.COM INC')
    expect(tax_records[0][1]).to eq('aktsia')
    expect(tax_records[0][2]).to eq(8)
    expect(tax_records[0][3]).to eq('2017-05-22')
    expect(tax_records[0][4]).to eq('TODO: country')
    expect(tax_records[0][5]).to eq('544.72')
    expect(tax_records[0][6]).to eq('0.35')
    expect(tax_records[0][7]).to eq('630.86')
  end

  def tax_report(data)
    trades = IbEstonia::Importer.import(data, exchange_rate_fetcher)
    records = IbEstonia::TaxReport.new(trades).generate_tax_records
    IbEstonia::EmtaFormatter.format(records)
  end
end
