module IbEstonia
  module Dividends
    class TaxRecord
      include Virtus.value_object

      values do
        attribute :date, Date
        attribute :gross_amount, BigDecimal, default: 0
        attribute :tax, BigDecimal, default: 0
        attribute :currency, String
        attribute :symbol, SymbolInfo
      end

      def increase(gross_amount: 0, tax: 0)
        with(
          gross_amount: self.gross_amount + gross_amount,
          tax: self.tax + tax
        )
      end
    end
  end
end
