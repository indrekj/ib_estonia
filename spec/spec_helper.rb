require 'ib_estonia'

def buy_stock(opts = {})
  generate_stock_trade('BUY', opts)
end

def sell_stock(opts = {})
  generate_stock_trade('SELL', opts)
end

def generate_stock_trade(type, opts = {})
  IbEstonia::Stocks::Trade.new({
    date: next_day.strftime("%Y%m%d"),
    type: type,
    quantity: 5,
    price: '122.45',
    commission: 0,
    currency: 'USD',
    symbol: {ticker: 'VOO', description: 'S&P500'}
  }.merge(opts))
end

def next_day
  @next_day ||= Time.local(2017, 01, 01)
  @next_day += 60*60*24
end
