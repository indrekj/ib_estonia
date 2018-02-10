module IbEstonia
  module Symbols
    class Importer
      def self.import(data, isin_fetcher)
        doc = Nokogiri::XML(data)
        fetch_symbols(doc, isin_fetcher)
      end

      def self.fetch_symbols(doc, isin_fetcher)
        doc.xpath("//SecurityInfo")
          .map(&:attributes)
          .each do |record|
            record.each {|key, val| record[key] = val.value}
          end
          .map do |record|
            SymbolInfo.new(
              name: record['symbol'],
              description: record['description'],
              isin: presence(record['isin']) || isin_fetcher.fetch(record['symbol'])
            )
          end
      end

      def self.presence(str)
        str.empty? ? nil : str
      end
    end
  end
end
