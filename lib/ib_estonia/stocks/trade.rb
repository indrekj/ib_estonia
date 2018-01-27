module IbEstonia
  module Stocks
    class Trade
      include Virtus.value_object

      values do
        attribute :date, Date # Settlement date
        attribute :type, String # BUY/SELL
        attribute :quantity, Integer
        attribute :price, BigDecimal
        attribute :commission, BigDecimal
        attribute :currency, String
        attribute :symbol, SymbolInfo
      end

      def amount
        quantity * price
      end

      def to_s
        [
          date,
          type,
          "#{quantity}x#{Format(price)}",
          Format(amount),
          currency
        ].join("\t")
      end
    end
  end
end
