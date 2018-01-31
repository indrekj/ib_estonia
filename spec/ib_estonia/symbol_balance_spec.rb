require 'spec_helper'

describe IbEstonia::SymbolBalance do
  let(:balance) { described_class.new }

  it 'adds commission to open amount on close' do
    balance << buy_stock(quantity: 6, price: 100, commission: 4.0)
    amount, commission = balance.close(6)
    expect(amount).to eq(600.0)
    expect(commission).to eq(4.0)
  end

  it 'adds partial commission to open amount on partial close' do
    balance << buy_stock(quantity: 6, price: 100, commission: 4.0)
    amount, commission = balance.close(3)
    expect(amount).to eq(300.0)
    expect(commission).to eq(2.0)
  end
end
