require_relative './format'
require_relative './stock_tax_record'

class StockTaxReport
  def initialize(trades)
    @trades_by_symbol = trades
      .sort_by(&:date)
      .group_by(&:symbol)
  end

  def generate_tax_records
    @trades_by_symbol.reduce([]) do |tax_records, (symbol, trades)|
      tax_records + generate_tax_records_for_symbol(symbol, trades)
    end
  end

  def print
    generate_tax_records.each do |record|
      puts record
    end
  end

  private

  def generate_tax_records_for_symbol(symbol, trades)
    seen_trades = []
    first_trade_type = trades[0].type

    trades.reduce([]) do |tax_records, trade|
      if trade.type != first_trade_type
        avg_open_price = calc_avg_price(seen_trades)

        tax_record = StockTaxRecord.new(
          type: trade.type,
          symbol: symbol,
          date: trade.date,
          quantity: trade.quantity.abs,
          close_price: trade.price,
          avg_open_price: avg_open_price
        )

        seen_trades << Trade.new(
          quantity: -1 * tax_record.quantity,
          price: avg_open_price
        )

        tax_records + [tax_record]
      else
        seen_trades << trade
        tax_records
      end
    end
  end

  def calc_avg_price(seen_trades)
    amount = seen_trades.reduce(0) {|sum, x| sum + x.amount}
    quantity = seen_trades.reduce(0) {|sum, x| sum + x.quantity}
    amount / quantity
  end
end
