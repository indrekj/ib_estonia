module IbEstonia
  module Trades
    class Importer
      def self.import(data, exchange_rate_fetcher)
        doc = Nokogiri::XML(data)
        symbols = fetch_symbols(doc)
        (
          fetch_stock_trades(doc, symbols) +
          fetch_option_trades(doc, symbols)
        ).map {|trade| change_currency(trade, exchange_rate_fetcher)}
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

      def self.fetch_stock_trades(doc, symbols)
        doc.xpath("//Trade[@assetCategory='STK']")
          .map(&:attributes)
          .each do |record|
            record.each {|key, val| record[key] = val.value}
          end
          .reject do |record|
            # Not sure why these are even listed here. Only seen happening with frac
            # share after a reverse split.
            #
            # Rejecting reverse splits because we don't currently support them.
            record['transactionType'] == 'FracShare' ||
              record['transactionType'] == 'FracShareCancel'
          end
          .map do |record|
            StockTrade.new(
              date: record['settleDateTarget'],
              type: record['buySell'],
              quantity: record['quantity'].to_i.abs,
              price: record['tradePrice'],
              commission: BigDecimal(record['ibCommission']).abs,
              currency: record['currency'],
              symbol: symbols.detect {|symbol| symbol.name == record['symbol']}
            )
          end
      end

      def self.fetch_option_trades(doc, symbols)
        doc.xpath("//Trade[@assetCategory='OPT']")
          .map(&:attributes)
          .each do |record|
            record.each {|key, val| record[key] = val.value}
          end
          .map do |record|
            OptionTrade.new(
              date: record['settleDateTarget'],
              type: record['buySell'],
              quantity: record['quantity'].to_i.abs,
              price: record['tradePrice'],
              commission: BigDecimal(record['ibCommission']).abs,
              currency: record['currency'],
              symbol: symbols.detect {|symbol| symbol.name == record['symbol']},
              strike: BigDecimal(record['strike']),
              multiplier: record['multiplier'].to_i
            )
          end
      end

      def self.change_currency(trade, exchange_rate_fetcher)
        trade.with(
          currency: 'EUR',
          price: exchange_rate_fetcher.convert(
            amount: trade.price,
            from: trade.currency,
            to: 'EUR',
            date: trade.date
          ),
          commission: exchange_rate_fetcher.convert(
            amount: trade.commission,
            from: trade.currency,
            to: 'EUR',
            date: trade.date
          )
        )
      end

      def self.presence(str)
        str.empty? ? nil : str
      end
    end
  end
end
