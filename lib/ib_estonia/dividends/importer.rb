module IbEstonia
  module Dividends
    class Importer
      def self.import(data, symbols)
        doc = Nokogiri::XML(data)
        (
          fetch_dividends(doc, symbols) +
          fetch_witholding_taxes(doc, symbols)
        )
      end

      def self.fetch_dividends(doc, symbols)
        doc.xpath("//CashTransaction[@type='Dividends']")
          .map(&:attributes)
          .each do |record|
            record.each {|key, val| record[key] = val.value}
          end
          .map do |record|
            Dividend.new(
              date: record['reportDate'],
              gross_amount: record['amount'],
              currency: record['currency'],
              datetime_identifier: record['dateTime'],
              symbol: symbols.detect {|symbol| symbol.conid == record['conid']}
            )
          end
      end

      def self.fetch_witholding_taxes(doc, symbols)
        doc.xpath("//CashTransaction[@type='Withholding Tax']")
          .map(&:attributes)
          .each do |record|
            record.each {|key, val| record[key] = val.value}
          end
          .map do |record|
            WithholdingTax.new(
              date: record['reportDate'],
              amount: BigDecimal(record['amount']).abs,
              currency: record['currency'],
              datetime_identifier: record['dateTime'],
              symbol: symbols.detect {|symbol| symbol.conid == record['conid']}
            )
          end
      end
    end
  end
end
