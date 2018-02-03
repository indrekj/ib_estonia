module IbEstonia
  class TaxRecord
    include Virtus.value_object

    values do
      attribute :security_type, String
      attribute :type, String # BUY/SELL
      attribute :symbol, SymbolInfo
      attribute :date, Date
      attribute :currency, String
      attribute :quantity, Integer
      attribute :close_commission, BigDecimal
      attribute :close_price, BigDecimal
      attribute :open_amount, BigDecimal
      attribute :open_commission, BigDecimal
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
        symbol.name,
        from_position,
        date,
        "#{quantity}x#{Format(close_price)}",
        "open: #{Format(open_amount)}",
        "close: #{Format(close_amount)}",
        "profit: #{Format(profit)}",
        currency
      ].join("\t")
    end
  end
end
