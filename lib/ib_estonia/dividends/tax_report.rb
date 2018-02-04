module IbEstonia
  module Dividends
    class TaxReport
      def initialize(records)
        @accruals = records.select {|r| r.is_a?(Dividend)}
        @withholding_taxes = records.select {|r| r.is_a?(WithholdingTax)}
      end

      def generate_tax_records
        tax_records_by_date = {}

        @accruals.each do |accrual|
          date = accrual.date
          name = accrual.symbol.name

          tax_records_by_date[date] ||= {}
          tax_records_by_date[date][name] ||= TaxRecord.new(
            date: accrual.date,
            currency: accrual.currency,
            symbol: accrual.symbol
          )
          tax_records_by_date[date][name] =
            tax_records_by_date[date][name].increase(gross_amount: accrual.gross_amount)
        end

        @withholding_taxes.each do |withholding_tax|
          date = withholding_tax.date
          name = withholding_tax.symbol.name

          tax_records_by_date[date] ||= {}
          if tax_record = tax_records_by_date[date][name]
            tax_records_by_date[date][name] =
              tax_record.increase(tax: withholding_tax.amount)
          else
            puts "Found 'withholding tax' record without Dividend Accrual record: #{withholding_tax.inspect}"
          end
        end

        tax_records_by_date.values.flat_map(&:values)
      end

      def print
        table = Terminal::Table.new(
          rows: EmtaFormatter.format(generate_tax_records)
        )
        puts table
      end
    end
  end
end
