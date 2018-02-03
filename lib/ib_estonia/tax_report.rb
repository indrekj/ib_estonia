module IbEstonia
  class TaxReport
    def initialize(trades)
      @trades_by_symbol = trades
        .sort_by(&:date)
        .group_by(&:symbol)
    end

    def generate_tax_records
      @trades_by_symbol.reduce([]) do |tax_records, (symbol, trades)|
        tax_records + generate_tax_records_for_symbol(symbol, trades)
      end
    end

    def print
      table = Terminal::Table.new(
        rows: EmtaFormatter.format(generate_tax_records)
      )
      puts table
    end

    private

    def generate_tax_records_for_symbol(symbol, trades)
      symbol_balance = SymbolBalance.new

      trades.reduce([]) do |tax_records, trade|
        if symbol_balance.should_close?(trade)
          open_amount, open_commission = symbol_balance.close(trade.quantity)

          tax_record = TaxRecord.new(
            security_type: trade.security_type,
            type: trade.type,
            symbol: symbol,
            date: trade.date,
            currency: trade.currency,
            quantity: trade.quantity.abs,
            close_commission: trade.commission,
            close_price: trade.price * trade.multiplier,
            open_amount: open_amount,
            open_commission: open_commission
          )

          tax_records + [tax_record]
        else
          symbol_balance << trade
          tax_records
        end
      end
    end
  end
end
