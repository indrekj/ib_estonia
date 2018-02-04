module IbEstonia
  module Dividends
    # See https://www.emta.ee/sites/default/files/eraklient/tulu-deklareerimine/deklaratsioonide-vormid/2017/tabel_8.8.pdf
    module EmtaFormatter
      def self.format(tax_records)
        tax_records
          .sort_by(&:date)
          .map(&method(:format_record))
      end

      def self.format_record(tax_record)
        [
          'TODO: ISIN',
          name(tax_record),
          country(tax_record),
          'dividend',
          tax_record.date.strftime("%Y-%m-%d"),
          tax_record.currency,
          Format(tax_record.gross_amount),
          withheld_tax(tax_record),
          withheld_tax_date(tax_record)
        ]
      end

      def self.name(tax_record)
        symbol = tax_record.symbol
        "#{symbol.name}: #{symbol.description}"
      end

      def self.country(tax_record)
        "TODO: country"
      end

      def self.withheld_tax(tax_record)
        Format(tax_record.tax)
      end

      def self.withheld_tax_date(tax_record)
        tax_record.date
      end
    end
  end
end
