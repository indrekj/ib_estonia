require 'spec_helper'

describe IbEstonia::Dividends::TaxReport do
  it 'returns empty list when no dividends' do
    expect(generate([])).to eq([])
  end

  it 'returns one record when one dividend accrual' do
    tax_records = generate([
      generate_dividend(gross_amount: 5.43)
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].gross_amount).to eq(5.43)
    expect(tax_records[0].tax).to eq(0)
  end

  it 'returns one record when one dividend accrual with tax' do
    date = '20170516'
    tax_records = generate([
      generate_dividend(gross_amount: 5.43, date: date),
      generate_withholding_tax(amount: 1.1, date: date)
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].gross_amount).to eq(5.43)
    expect(tax_records[0].tax).to eq(1.1)
  end

  it 'returns one record when multiple dividend accrual on the same day' do
    date = '20170516'
    tax_records = generate([
      generate_dividend(gross_amount: 5.43, date: date),
      generate_withholding_tax(amount: 1.1, date: date),
      generate_dividend(gross_amount: 2.22, date: date),
      generate_withholding_tax(amount: 1.2, date: date)
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].gross_amount).to eq(7.65)
    expect(tax_records[0].tax).to eq(2.3)
  end

  it 'returns one record when tax withheld on a different day' do
    datetime_identifier = '20170516;20200'
    tax_records = generate([
      generate_dividend(gross_amount: 5.43, date: '20170516', datetime_identifier: datetime_identifier),
      generate_withholding_tax(amount: 1.1, date: '20170516', datetime_identifier: datetime_identifier),
      # E.g. IB or somebody made a mistake, now they revert previous
      # transaction and create a new one
      generate_withholding_tax(amount: -1.1, date: '20170520', datetime_identifier: datetime_identifier),
      generate_withholding_tax(amount: 2.1, date: '20170520', datetime_identifier: datetime_identifier)
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].gross_amount).to eq(5.43)
    expect(tax_records[0].tax).to eq(2.1)
  end

  def generate(trades)
    exchange_rate_fetcher = double
    described_class.new(trades, exchange_rate_fetcher).generate_tax_records
  end

  def generate_dividend(opts)
    date = opts[:date] || next_day.strftime("%Y%m%d")
    datetime_identifier = "#{date};20200"

    IbEstonia::Dividends::Dividend.new({
      date: date,
      gross_amount: 10.0,
      currency: 'USD',
      symbol: {name: 'VOO', description: 'S&P500', isin: 'US9229083632'},
      datetime_identifier: datetime_identifier
    }.merge(opts))
  end

  def generate_withholding_tax(opts)
    date = opts[:date] || next_day.strftime("%Y%m%d")
    datetime_identifier = "#{date};20200"

    IbEstonia::Dividends::WithholdingTax.new({
      date: date,
      amount: 2.0,
      currency: 'USD',
      symbol: {name: 'VOO', description: 'S&P500', isin: 'US9229083632'},
      datetime_identifier: datetime_identifier
    }.merge(opts))
  end
end
