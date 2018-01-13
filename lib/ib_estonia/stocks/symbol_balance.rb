module IbEstonia
  module Stocks
    class SymbolBalance
      def initialize
        @open_trades = []
      end

      def close(quantity)
        amount = 0
        commission = 0

        while quantity != 0
          close_amount, close_commission =
            if @open_trades[0].remaining_quantity <= quantity
              trade = @open_trades.shift
              quantity -= trade.remaining_quantity
              trade.close(trade.remaining_quantity)
            else
              trade = @open_trades[0]
              result = trade.close(quantity)
              quantity = 0
              result
            end

          amount += close_amount
          commission += close_commission
        end

        [amount, commission]
      end

      def <<(trade)
        @open_trades << OpenTrade.new(
          type: trade.type,
          quantity: trade.quantity,
          price: trade.price,
          commission: trade.commission
        )
      end

      def should_close?(trade)
        return false if @open_trades.empty?
        @open_trades[0].type != trade.type
      end

      class OpenTrade
        include Virtus.model

        attribute :type, String
        attribute :quantity, Integer
        attribute :price, BigDecimal
        attribute :commission, BigDecimal
        attribute :closed_quantity, Integer, default: 0

        def remaining_quantity
          quantity - closed_quantity
        end

        def close(quantity_to_close)
          if quantity_to_close > remaining_quantity
            raise "Trying to close more than remaining"
          end

          amount = quantity_to_close * price
          amount_commission = commission * (BigDecimal(quantity_to_close) / BigDecimal(quantity))

          self.closed_quantity += quantity_to_close

          [amount, amount_commission]
        end
      end
    end
  end
end
