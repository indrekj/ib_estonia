module IbEstonia
  class SymbolInfo
    include Virtus.value_object

    values do
      attribute :name, String
      attribute :description, String
      attribute :isin, String
      attribute :conid, String
    end

    def country
      isin ? isin[0...2] : nil
    end
  end
end
