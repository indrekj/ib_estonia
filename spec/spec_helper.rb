require 'ib_estonia'

def buy_stock(opts = {})
  generate_stock_trade('BUY', opts)
end

def sell_stock(opts = {})
  generate_stock_trade('SELL', opts)
end

def buy_call(opts = {})
  generate_option_trade('BUY', opts)
end

def sell_call(opts = {})
  generate_option_trade('SELL', opts)
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

def generate_option_trade(type, opts = {})
  IbEstonia::Options::Trade.new({
    date: next_day.strftime("%Y%m%d"),
    type: type,
    quantity: 5,
    price: '1.87',
    commission: 0,
    currency: 'USD',
    symbol: {ticker: 'AMD   170217C00010000', description: 'AMD 17FEB17 10.0 C'},
    strike: '10.0',
    multiplier: 100
  }.merge(opts))
end

def next_day
  @next_day ||= Time.local(2017, 01, 01)
  @next_day += 60*60*24
end
