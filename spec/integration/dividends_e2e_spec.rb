require 'spec_helper'

describe 'Dividends E2E' do
  it 'generates tax report for simple stock sell' do
    tax_records = tax_report(read_fixture('dividend.xml'))

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('US4642864007')
    expect(tax_records[0][1]).to eq('EWZ: ISHARES MSCI BRAZIL CAPPED E')
    expect(tax_records[0][2]).to eq('US')
    expect(tax_records[0][3]).to eq('dividend')
    expect(tax_records[0][4]).to eq('USD')
    expect(tax_records[0][5]).to eq('8.31')
    expect(tax_records[0][6]).to eq('26.06.2017')
    expect(tax_records[0][7]).to eq('1.25')
  end

  def tax_report(data)
    isin_fetcher = double(fetch: 'US4642864007')
    exchange_rate_fetcher = double(convert: nil)
    symbols = IbEstonia::Symbols::Importer.import(data, isin_fetcher)
    records = IbEstonia::Dividends::Importer.import(data, symbols)
    report = IbEstonia::Dividends::TaxReport.new(records, exchange_rate_fetcher)
      .generate_tax_records
    IbEstonia::Dividends::EmtaFormatter.format(report, exchange_rate_fetcher)
  end
end
