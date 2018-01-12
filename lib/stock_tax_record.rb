require 'virtus'

class StockTaxRecord
  include Virtus.value_object

  values do
    attribute :symbol, String
    attribute :date, String
    attribute :quantity, Integer
    attribute :price, Decimal
    attribute :avg_buy_price, Decimal
  end

  def profit
    sell_amount - buy_amount
  end

  def buy_amount
    quantity * avg_buy_price
  end

  def sell_amount
    quantity * price
  end

  def to_s
    [
      symbol,
      date,
      "#{quantity}x#{Format(price)}",
      "bought: #{Format(buy_amount)}",
      "sold: #{Format(sell_amount)}",
      "profit: #{Format(profit)}"
    ].join("\t")
  end
end
