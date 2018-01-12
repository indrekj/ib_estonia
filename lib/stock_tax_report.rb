require_relative './format'
require_relative './stock_tax_record'

class StockTaxReport
  def initialize(trades)
    @trades_by_symbol = trades
      .sort_by(&:date)
      .group_by(&:symbol)
  end

  def generate_tax_records
    tax_records = []

    @trades_by_symbol.each do |symbol, trades|
      trades = trades.sort_by(&:date)
      next if trades[0].type != 'BUY'

      seen_trades = []
      trades.each do |trade|
        if trade.type == 'SELL'
          avg_buy_price = calc_avg_price(seen_trades)

          tax_record = StockTaxRecord.new(
            symbol: symbol,
            date: trade.date,
            quantity: trade.quantity.abs,
            price: trade.price,
            avg_buy_price: avg_buy_price
          )

          seen_trades << Trade.new(
            quantity: -1 * tax_record.quantity,
            price: avg_buy_price
          )
          tax_records << tax_record
        else
          seen_trades << trade
        end
      end
    end

    tax_records
  end

  def print
    generate_tax_records.each do |record|
      puts record
    end
  end

  def calc_avg_price(seen_trades)
    amount = seen_trades.reduce(0) {|sum, x| sum + x.amount}
    quantity = seen_trades.reduce(0) {|sum, x| sum + x.quantity}
    amount / quantity
  end
end
