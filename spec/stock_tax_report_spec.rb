require 'stock_tax_report'
require 'trade'

describe StockTaxReport do
  it 'returns empty list when no trades' do
    expect(generate([])).to eq([])
  end

  it 'returns empty list when only long trades' do
    trade1 = generate_long_trade
    trade2 = generate_long_trade
    expect(generate([trade1, trade2])).to eq([])
  end

  it 'returns one record when closing long position fully' do
    tax_records = generate([
      generate_long_trade(quantity: 5, price: 105.3),
      generate_short_trade(quantity: 5, price: 110.2)
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].profit).to eq(24.5)
  end

  it 'returns multiple records when closing long position in chunks' do
    tax_records = generate([
      generate_long_trade(quantity: 5, price: 105.3),
      generate_short_trade(quantity: 2, price: 110.1),
      generate_short_trade(quantity: 3, price: 114.9)
    ])

    expect(tax_records.count).to eq(2)
    expect(tax_records[0].profit).to eq(9.6)
    expect(tax_records[1].profit).to eq(28.8)
  end

  it 'returns multiple records when buying/selling long position multiple times' do
    tax_records = generate([
      generate_long_trade(quantity: 5, price: 105.3),
      generate_short_trade(quantity: 2, price: 110.1),
      generate_long_trade(quantity: 3, price: 109.2),
      generate_short_trade(quantity: 1, price: 114.8),
      generate_short_trade(quantity: 5, price: 116.1)
    ])

    expect(tax_records.count).to eq(3)
    expect(tax_records[0].profit).to eq(9.60)
    expect(tax_records[1].profit).to eq(7.55)
    expect(tax_records[2].profit).to eq(44.25)
  end

  def generate(trades)
    described_class.new(trades).generate_tax_records
  end

  def generate_long_trade(opts = {})
    generate_trade('BUY', opts)
  end

  def generate_short_trade(opts = {})
    generate_trade('SELL', opts)
  end

  def generate_trade(buy_sell, opts = {})
    Trade.new({
      date: next_day.strftime("%Y%m%d"),
      type: buy_sell,
      quantity: 5,
      price: '122.45',
      currency: 'USD',
      symbol: 'VOO'
    }.merge(opts))
  end

  def next_day
    @next_day ||= Time.local(2017, 01, 01)
    @next_day += 60*60*24
  end
end
