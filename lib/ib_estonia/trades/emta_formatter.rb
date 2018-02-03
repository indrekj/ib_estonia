module IbEstonia
  module Trades
    # See https://www.emta.ee/sites/default/files/eraklient/tulu-deklareerimine/deklaratsioonide-vormid/2017/tabel_8.2.pdf
    module EmtaFormatter
      def self.format(tax_records)
        tax_records
          .sort_by(&:date)
          .map(&method(:format_record))
      end

      def self.format_record(tax_record)
        [
          name(tax_record),
          security_type(tax_record),
          tax_record.quantity,
          tax_record.date.strftime("%Y-%m-%d"),
          country(tax_record),
          open_amount(tax_record),
          close_commission(tax_record),
          close_amount(tax_record),
          0
        ]
      end

      def self.security_type(tax_record)
        if tax_record.security_type == SecurityType::STOCK
          'aktsia'
        elsif tax_record.security_type == SecurityType::OPTION
          'optsioon'
        else
          'unknown'
        end
      end

      def self.name(tax_record)
        symbol = tax_record.symbol

        if tax_record.closing_long?
          "#{symbol.name}: #{symbol.description}"
        else
          "#{symbol.name}: #{symbol.description}**"
        end
      end

      def self.country(tax_record)
        "TODO: country"
      end

      def self.open_amount(tax_record)
        if tax_record.closing_long?
          Format(tax_record.open_amount + tax_record.open_commission)
        else
          Format(tax_record.close_amount + tax_record.close_commission)
        end
      end

      def self.close_amount(tax_record)
        if tax_record.closing_long?
          Format(tax_record.close_amount)
        else
          Format(tax_record.open_amount)
        end
      end

      def self.close_commission(tax_record)
        if tax_record.closing_long?
          Format(tax_record.close_commission)
        else
          Format(tax_record.open_commission)
        end
      end
    end
  end
end
