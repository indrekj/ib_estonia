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

  def generate(trades)
    exchange_rate_fetcher = double
    described_class.new(trades, exchange_rate_fetcher).generate_tax_records
  end

  def generate_dividend(opts)
    IbEstonia::Dividends::Dividend.new({
      date: next_day.strftime("%Y%m%d"),
      gross_amount: 10.0,
      currency: 'USD',
      symbol: {name: 'VOO', description: 'S&P500', isin: 'US9229083632'}
    }.merge(opts))
  end

  def generate_withholding_tax(opts)
    IbEstonia::Dividends::WithholdingTax.new({
      date: next_day.strftime("%Y%m%d"),
      amount: 2.0,
      currency: 'USD',
      symbol: {name: 'VOO', description: 'S&P500', isin: 'US9229083632'}
    }.merge(opts))
  end
end
