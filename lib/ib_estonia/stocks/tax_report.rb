module IbEstonia
  module Stocks
    class TaxReport
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
        EmtaFormatter.format(generate_tax_records)
          .each {|record| puts record.join("\t")}
      end

      private

      def generate_tax_records_for_symbol(symbol, trades)
        symbol_balance = SymbolBalance.new

        trades.reduce([]) do |tax_records, trade|
          if symbol_balance.should_close?(trade)
            open_amount = symbol_balance.close(trade.quantity)

            tax_record = TaxRecord.new(
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
            symbol_balance << trade
            tax_records
          end
        end
      end
    end
  end
end
