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
            isin =
              if !record['isin'].empty?
                record['isin']
              elsif record['assetCategory'] == 'STK'
                isin_fetcher.fetch(record['symbol'])
              elsif record['assetCategory'] == 'OPT'
                isin_fetcher.fetch(record['underlyingSymbol'])
              end

            SymbolInfo.new(
              name: record['symbol'],
              description: record['description'],
              isin: isin
            )
          end
      end
    end
  end
end
