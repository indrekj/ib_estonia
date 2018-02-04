module IbEstonia
  module Dividends
    class WithholdingTax
      include Virtus.value_object

      values do
        attribute :date, Date
        attribute :amount, BigDecimal
        attribute :currency, String
        attribute :symbol, SymbolInfo
      end
    end
  end
end
