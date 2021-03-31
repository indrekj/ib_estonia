module IbEstonia
  module Dividends
    class Dividend
      include Virtus.value_object

      values do
        attribute :date, Date
        attribute :gross_amount, BigDecimal
        attribute :currency, String
        attribute :symbol, SymbolInfo
        attribute :datetime_identifier, String
      end
    end
  end
end
