require 'virtus'

class StockTaxRecord
  include Virtus.value_object

  values do
    attribute :type, String # BUY/SELL
    attribute :symbol, String
    attribute :date, String
    attribute :quantity, Integer
    attribute :close_price, Decimal
    attribute :avg_open_price, Decimal
  end

  def closing_long?
    type == 'SELL'
  end

  def from_position
    closing_long? ? 'LONG' : 'SHORT'
  end

  def profit
    if closing_long?
      sell_amount - buy_amount
    else
      buy_amount - sell_amount
    end
  end

  def buy_amount
    quantity * avg_open_price
  end

  def sell_amount
    quantity * close_price
  end

  def to_s
    [
      symbol,
      from_position,
      date,
      "#{quantity}x#{Format(close_price)}",
      "bought: #{Format(buy_amount)}",
      "sold: #{Format(sell_amount)}",
      "profit: #{Format(profit)}"
    ].join("\t")
  end
end
