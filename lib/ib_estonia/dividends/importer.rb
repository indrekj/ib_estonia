module IbEstonia
  module Dividends
    class Importer
      def self.import(data)
        doc = Nokogiri::XML(data)
        symbols = fetch_symbols(doc)
        (
          fetch_dividends(doc, symbols) +
          fetch_witholding_taxes(doc, symbols)
        )
      end

      def self.fetch_symbols(doc)
        doc.xpath("//SecurityInfo")
          .map(&:attributes)
          .each do |record|
            record.each {|key, val| record[key] = val.value}
          end
          .map do |record|
            SymbolInfo.new(
              name: record['symbol'],
              description: record['description'],
              isin: presence(record['isin'])
            )
          end
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
              symbol: symbols.detect {|symbol| symbol.name == record['symbol']}
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
              symbol: symbols.detect {|symbol| symbol.name == record['symbol']}
            )
          end
      end

      def self.presence(str)
        str.empty? ? nil : str
      end
    end
  end
end
