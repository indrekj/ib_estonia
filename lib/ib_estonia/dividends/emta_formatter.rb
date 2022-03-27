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
          tax_record.symbol.isin || 'ISIN NOT FOUND',
          name(tax_record),
          tax_record.symbol.country || 'COUNTRY NOT FOUND',
          'dividend',
          tax_record.currency,
          tax_record.gross_amount,
          tax_record.date.strftime("%d.%m.%Y"),
          tax_record.tax,
          withheld_tax_date(tax_record)
        ].map(&method(:Format))
      end

      def self.format_sum_in_euros(tax_records, exchange_rate_fetcher)
        total_gross_amount = tax_records.sum do |tax_record|
          in_euros(tax_record, :gross_amount, exchange_rate_fetcher)
        end
        total_witheld_tax = tax_records.sum do |tax_record|
          in_euros(tax_record, :tax, exchange_rate_fetcher)
        end

        [
          nil,
          nil,
          nil,
          nil,
          'IN EUROS:',
          total_gross_amount,
          nil,
          total_witheld_tax,
          nil
        ].map(&method(:Format))
      end

      def self.name(tax_record)
        symbol = tax_record.symbol
        "#{symbol.name}: #{symbol.description}"
      end

      def self.withheld_tax_date(tax_record)
        tax_record.date.strftime('%d.%m.%Y')
      end

      def self.in_euros(tax_record, field, exchange_rate_fetcher)
        exchange_rate_fetcher.convert(
          amount: tax_record.public_send(field),
          from: tax_record.currency,
          to: 'EUR',
          date: tax_record.date
        )
      end
    end
  end
end
