require 'virtus'

class SymbolInfo
  include Virtus.value_object

  values do
    attribute :ticker, String
    attribute :description, String
  end
end
