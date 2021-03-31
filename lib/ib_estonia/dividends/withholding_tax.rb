module IbEstonia
  module Dividends
    class WithholdingTax
      include Virtus.value_object

      values do
        attribute :date, Date
        attribute :amount, BigDecimal
        attribute :currency, String
        attribute :symbol, SymbolInfo
        attribute :datetime_identifier, String
      end
    end
  end
end
