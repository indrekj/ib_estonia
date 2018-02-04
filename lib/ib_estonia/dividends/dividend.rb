module IbEstonia
  module Dividends
    class Dividend
      include Virtus.value_object

      values do
        attribute :date, Date
        attribute :gross_amount, BigDecimal
        attribute :currency, String
        attribute :symbol, SymbolInfo
      end
    end
  end
end
