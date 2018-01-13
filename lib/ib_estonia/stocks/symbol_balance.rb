module IbEstonia
  module Stocks
    class SymbolBalance
      def initialize
        @open_trades = []
      end

      def close(quantity)
        amount = 0

        while quantity != 0
          if @open_trades[0].remaining_quantity <= quantity
            trade = @open_trades.shift
            quantity -= trade.remaining_quantity
            amount += trade.close(trade.remaining_quantity)
          else
            trade = @open_trades[0]
            amount += trade.close(quantity)
            quantity = 0
          end
        end

        amount
      end

      def <<(trade)
        @open_trades << OpenTrade.new(
          type: trade.type,
          quantity: trade.quantity,
          price: trade.price,
          commision: 0
        )
      end

      def should_close?(trade)
        return false if @open_trades.empty?
        @open_trades[0].type != trade.type
      end

      class OpenTrade
        include Virtus.model

        attribute :type
        attribute :quantity
        attribute :price
        attribute :commision
        attribute :closed_quantity, Integer, default: 0

        def remaining_quantity
          quantity - closed_quantity
        end

        def close(quantity_to_close)
          if quantity_to_close > remaining_quantity
            raise "Trying to close more than remaining"
          end

          amount = quantity_to_close * price +
            commision * (closed_quantity / quantity_to_close)

          self.closed_quantity += quantity_to_close

          amount
        end
      end
    end
  end
end
