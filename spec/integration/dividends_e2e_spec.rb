require 'spec_helper'

describe 'Dividends E2E' do
  it 'generates tax report for simple stock sell' do
    tax_records = tax_report(read_fixture('dividend.xml'))

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('TODO: ISIN')
    expect(tax_records[0][1]).to eq('EWZ: ISHARES MSCI BRAZIL CAPPED E')
    expect(tax_records[0][2]).to eq('TODO: country')
    expect(tax_records[0][3]).to eq('dividend')
    expect(tax_records[0][4]).to eq('2017-06-26')
    expect(tax_records[0][5]).to eq('USD')
    expect(tax_records[0][6]).to eq('8.31')
    expect(tax_records[0][7]).to eq('1.25')
  end

  def tax_report(data)
    records = IbEstonia::Dividends::Importer.import(data)
    report = IbEstonia::Dividends::TaxReport.new(records).generate_tax_records
    IbEstonia::Dividends::EmtaFormatter.format(report)
  end
end
