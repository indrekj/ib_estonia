module IbEstonia
  class SymbolInfo
    include Virtus.value_object

    values do
      attribute :name, String
      attribute :description, String
      attribute :isin, String
    end

    # From https://www.interactivebrokers.com/en/software/reportguide/reportguide/financialinstrumentinformationfq.htm
    #   CUSIP information is available only if you are subscribed to the CUSIP
    #   Service market data subscription, but ISIN will appear for non-US
    #   products and other products where applicable.
    def country
      isin ? isin[0...2] : 'US'
    end
  end
end
