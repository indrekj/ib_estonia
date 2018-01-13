require 'ib_estonia'
require 'stocks_helper'

describe IbEstonia::Stocks::SymbolBalance do
  include StocksHelper

  let(:balance) { described_class.new }

  it 'adds commission to open amount on close' do
    balance << generate_long_trade(quantity: 6, price: 100, commission: 4.0)
    amount, commission = balance.close(6)
    expect(amount).to eq(600.0)
    expect(commission).to eq(4.0)
  end

  it 'adds partial commission to open amount on partial close' do
    balance << generate_long_trade(quantity: 6, price: 100, commission: 4.0)
    amount, commission = balance.close(3)
    expect(amount).to eq(300.0)
    expect(commission).to eq(2.0)
  end
end
