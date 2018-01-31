require 'spec_helper'

describe IbEstonia::TaxReport do
  it 'returns empty list when no trades' do
    expect(generate([])).to eq([])
  end

  it 'returns empty list when only long trades' do
    trade1 = buy_stock
    trade2 = buy_stock
    expect(generate([trade1, trade2])).to eq([])
  end

  it 'returns empty list when only short trades' do
    trade1 = sell_stock
    trade2 = sell_stock
    expect(generate([trade1, trade2])).to eq([])
  end

  it 'returns one record when closing long position fully' do
    tax_records = generate([
      buy_stock(quantity: 5, price: 105.3),
      sell_stock(quantity: 5, price: 110.2)
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].profit).to eq(24.5)
  end

  it 'returns one record when closing short position fully' do
    tax_records = generate([
      sell_stock(quantity: 2, price: 30.2),
      buy_stock(quantity: 2, price: 25.5),
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0].profit).to eq(9.4)
  end

  it 'returns multiple records when closing long position in chunks' do
    tax_records = generate([
      buy_stock(quantity: 5, price: 105.3),
      sell_stock(quantity: 2, price: 110.1),
      sell_stock(quantity: 3, price: 114.9)
    ])

    expect(tax_records.count).to eq(2)
    expect(tax_records[0].profit).to eq(9.6)
    expect(tax_records[1].profit).to eq(28.8)
  end

  it 'returns multiple records when closing short position in chunks' do
    tax_records = generate([
      sell_stock(quantity: 3, price: 30.0),
      buy_stock(quantity: 2, price: 24.0),
      buy_stock(quantity: 1, price: 16.0)
    ])

    expect(tax_records.count).to eq(2)
    expect(tax_records[0].profit).to eq(12.0)
    expect(tax_records[1].profit).to eq(14.0)
  end

  it 'returns multiple records when buying/selling long position multiple times' do
    tax_records = generate([
      buy_stock(quantity: 5, price: 105.3),
      sell_stock(quantity: 2, price: 110.1),
      buy_stock(quantity: 3, price: 109.2),
      sell_stock(quantity: 1, price: 114.8),
      sell_stock(quantity: 5, price: 116.1)
    ])

    expect(tax_records.count).to eq(3)
    expect(tax_records[0].profit).to eq(9.60)
    expect(tax_records[1].profit).to eq(9.5)
    expect(tax_records[2].profit).to eq(42.3)
  end

  it 'returns multiple records when buying/selling short position multiple times' do
    tax_records = generate([
      sell_stock(quantity: 5, price: 60.0),
      buy_stock(quantity: 2, price: 55.0),
      sell_stock(quantity: 3, price: 58.0),
      buy_stock(quantity: 1, price: 53.0),
      buy_stock(quantity: 5, price: 51.0)
    ])

    expect(tax_records.count).to eq(3)
    expect(tax_records[0].profit).to eq(10.0)
    expect(tax_records[1].profit).to eq(7.0)
    expect(tax_records[2].profit).to eq(39.0)
  end

  it 'returns multiple records when switching between short and long position' do
    tax_records = generate([
      # Starting short position
      sell_stock(quantity: 5, price: 45.0),

      # Closing short position
      buy_stock(quantity: 5, price: 40.0),

      # Starting long position
      buy_stock(quantity: 3, price: 70.0),

      # Closing long position
      sell_stock(quantity: 3, price: 78.0)
    ])

    expect(tax_records.count).to eq(2)
    expect(tax_records[0].profit).to eq(25.0)
    expect(tax_records[1].profit).to eq(24.0)
  end

  def generate(trades)
    described_class.new(trades).generate_tax_records
  end
end
