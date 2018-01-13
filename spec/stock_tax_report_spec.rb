require 'symbol_info'
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

  it 'returns empty list when only short trades' do
    trade1 = generate_short_trade
    trade2 = generate_short_trade
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

  it 'returns one record when closing short position fully' do
    tax_records = generate([
      generate_short_trade(quantity: 2, price: 30.2),
      generate_long_trade(quantity: 2, price: 25.5),
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].profit).to eq(9.4)
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

  it 'returns multiple records when closing short position in chunks' do
    tax_records = generate([
      generate_short_trade(quantity: 3, price: 30.0),
      generate_long_trade(quantity: 2, price: 24.0),
      generate_long_trade(quantity: 1, price: 16.0)
    ])

    expect(tax_records.count).to eq(2)
    expect(tax_records[0].profit).to eq(12.0)
    expect(tax_records[1].profit).to eq(14.0)
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
    expect(tax_records[1].profit).to eq(9.5)
    expect(tax_records[2].profit).to eq(42.3)
  end

  it 'returns multiple records when buying/selling short position multiple times' do
    tax_records = generate([
      generate_short_trade(quantity: 5, price: 60.0),
      generate_long_trade(quantity: 2, price: 55.0),
      generate_short_trade(quantity: 3, price: 58.0),
      generate_long_trade(quantity: 1, price: 53.0),
      generate_long_trade(quantity: 5, price: 51.0)
    ])

    expect(tax_records.count).to eq(3)
    expect(tax_records[0].profit).to eq(10.0)
    expect(tax_records[1].profit).to eq(7.0)
    expect(tax_records[2].profit).to eq(39.0)
  end

  it 'returns multiple records when switching between short and long position' do
    tax_records = generate([
      # Starting short position
      generate_short_trade(quantity: 5, price: 45.0),

      # Closing short position
      generate_long_trade(quantity: 5, price: 40.0),

      # Starting long position
      generate_long_trade(quantity: 3, price: 70.0),

      # Closing long position
      generate_short_trade(quantity: 3, price: 78.0)
    ])

    expect(tax_records.count).to eq(2)
    expect(tax_records[0].profit).to eq(25.0)
    expect(tax_records[1].profit).to eq(24.0)
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

  def generate_trade(type, opts = {})
    Trade.new({
      date: next_day.strftime("%Y%m%d"),
      type: type,
      quantity: 5,
      price: '122.45',
      currency: 'USD',
      symbol: {ticker: 'VOO', description: 'S&P500'}
    }.merge(opts))
  end

  def next_day
    @next_day ||= Time.local(2017, 01, 01)
    @next_day += 60*60*24
  end
end
