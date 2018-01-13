require_relative './format'
require_relative './stock_tax_record'
require_relative './emta_formatters/stock_formatter'

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
    EmtaFormatters::StockFormatter.format(generate_tax_records)
      .each {|record| puts record.join("\t")}
  end

  private

  class SymbolPortfolio
    def initialize
      @open_trades = []
    end

    def close(quantity)
      amount = 0

      while quantity != 0
        if @open_trades[0].remaining_quantity <= quantity
          trade = @open_trades.shift
          quantity -= trade.remaining_quantity
          amount += trade.close(trade.remaining_quantity)
        else
          trade = @open_trades[0]
          amount += trade.close(quantity)
          quantity = 0
        end
      end

      amount
    end

    class OpenTrade
      include Virtus.model

      attribute :quantity
      attribute :price
      attribute :commision
      attribute :closed_quantity, Integer, default: 0

      def remaining_quantity
        quantity - closed_quantity
      end

      def close(quantity_to_close)
        if quantity_to_close > remaining_quantity
          raise "Trying to close more than remaining"
        end

        amount = quantity_to_close * price +
          commision * (closed_quantity / quantity_to_close)

        self.closed_quantity += quantity_to_close

        amount
      end
    end

    def <<(trade)
      @open_trades << OpenTrade.new(
        quantity: trade.quantity,
        price: trade.price,
        commision: 0
      )
    end
  end

  def generate_tax_records_for_symbol(symbol, trades)
    symbol_portfolio = SymbolPortfolio.new
    first_trade_type = trades[0].type

    trades.reduce([]) do |tax_records, trade|
      if trade.type != first_trade_type
        open_amount = symbol_portfolio.close(trade.quantity)

        tax_record = StockTaxRecord.new(
          type: trade.type,
          symbol: symbol,
          date: trade.date,
          currency: trade.currency,
          quantity: trade.quantity.abs,
          close_price: trade.price,
          open_amount: open_amount
        )

        tax_records + [tax_record]
      else
        symbol_portfolio << trade
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
