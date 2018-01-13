module IbEstonia
  module Stocks
    class TaxRecord
      include Virtus.value_object

      values do
        attribute :type, String # BUY/SELL
        attribute :symbol, SymbolInfo
        attribute :date, Date
        attribute :currency, String
        attribute :quantity, Integer
        attribute :close_price, Decimal
        attribute :open_amount, Decimal
      end

      def closing_long?
        type == 'SELL'
      end

      def from_position
        closing_long? ? 'LONG' : 'SHORT'
      end

      def profit
        if closing_long?
          close_amount - open_amount
        else
          open_amount - close_amount
        end
      end

      def close_amount
        quantity * close_price
      end

      def to_s
        [
          symbol.ticker,
          from_position,
          date,
          "#{quantity}x#{Format(close_price)}",
          "bought: #{Format(open_amount)}",
          "sold: #{Format(close_amount)}",
          "profit: #{Format(profit)}",
          currency
        ].join("\t")
      end
    end
  end
end
