module IbEstonia
  module Options
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
        attribute :strike, BigDecimal
        attribute :multiplier, Integer
      end

      def amount
        quantity * price * multiplier
      end

      def security_type
        SecurityType::OPTION
      end

      def to_s
        [
          "OPTION",
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
