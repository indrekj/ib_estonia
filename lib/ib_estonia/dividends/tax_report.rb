module IbEstonia
  module Dividends
    class TaxReport
      def initialize(records, exchange_rate_fetcher)
        @accruals = records.select {|r| r.is_a?(Dividend)}
        @withholding_taxes = records.select {|r| r.is_a?(WithholdingTax)}
        @exchange_rate_fetcher = exchange_rate_fetcher
      end

      def generate_tax_records
        return @_generated_tax_records if defined?(@_generated_tax_records)

        tax_records_by_id = {}

        @accruals.each do |accrual|
          id = accrual.datetime_identifier + accrual.symbol.isin

          tax_records_by_id[id] ||= TaxRecord.new(
            date: accrual.date,
            currency: accrual.currency,
            symbol: accrual.symbol
          )
          tax_records_by_id[id] = tax_records_by_id[id].increase(gross_amount: accrual.gross_amount)
        end

        @withholding_taxes.each do |withholding_tax|
          id = withholding_tax.datetime_identifier + withholding_tax.symbol.isin

          if (tax_record = tax_records_by_id[id])
            tax_records_by_id[id] = tax_record.increase(tax: withholding_tax.amount)
          else
            puts "Found 'withholding tax' record without Dividend Accrual record: #{withholding_tax.inspect}"
          end
        end

        @_generated_tax_records = tax_records_by_id.values
        @_generated_tax_records
      end

      def print(type)
        filtered_records = filter(generate_tax_records, type)
        records_by_year = filtered_records.group_by {|record| record.date.year}

        years = records_by_year.keys.sort
        last_two_years = years.last(2)

        table = Terminal::Table.new
        years.each do |year|
          if last_two_years.include?(year)
            table.add_row([year])
            table.add_separator
          else
            table.add_row([year, '(hidden)'])
            table.add_separator
            next
          end

          records = records_by_year[year].sort_by(&:date)

          EmtaFormatter.format(records, @exchange_rate_fetcher).each(&table.method(:add_row))
          table.add_separator
          table.add_row(EmtaFormatter.format_sum_in_euros(records, @exchange_rate_fetcher))
          table.add_separator if year < last_two_years.last
        end

        puts table
      end

      private

      def filter(records, type)
        if type == :with_tax
          records.filter {|r| r.tax.positive?}
        elsif type == :without_tax
          records.filter {|r| r.tax.zero?}
        else
          raise "Uknown type: #{type}"
        end
      end
    end
  end
end
