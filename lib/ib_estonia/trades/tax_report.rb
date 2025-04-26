module IbEstonia
  module Trades
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

      def generate_final_balances
        @trades_by_symbol.map do |(symbol, trades)|
          puts symbol.inspect
          [symbol, generate_final_balance(symbol, trades)]
        end
      end

      def print
        records_by_year = generate_tax_records.group_by {|record| record.date.year}

        years = records_by_year.keys.sort
        last_two_years = years.last(2)

        table = Terminal::Table.new
        years.each do |year|
          if last_two_years.include?(year)
            table.add_row([year])
            table.add_separator
          else
            table.add_row([year, '(hidden)'])
            table.add_separator
            next
          end

          records = records_by_year[year].sort_by(&:date)

          EmtaFormatter.format(records).each(&table.method(:add_row))
          table.add_separator
          table.add_row(EmtaFormatter.format_sum(records))
          table.add_separator if year < last_two_years.last
        end

        table.add_separator
        table.add_row(['FINAL BALANCE', 'ALL CURRENCIES ARE ALREADY IN EUROS'])
        table.add_separator
        sum = 0
        generate_final_balances.each do |symbol, balance|
          open_amount, open_commission = balance.close_remaining
          next if open_amount == 0
          sum += (open_amount + open_commission)

          table.add_row([symbol&.name, Format(open_amount), Format(open_commission)])
        end
        table.add_separator
        table.add_row(['TOTAL', Format(sum)])

        table.add_separator
        table.add_row(['TODO', 'WE STILL NEED TO ADD CASH BALANCES'])
        table.add_row(['TODO', 'HOW DO WE CONVERT USD CASH BALANCE TO EUROS??'])

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

      def generate_final_balance(_symbol, trades)
        symbol_balance = SymbolBalance.new

        trades.each do |trade|
          if symbol_balance.should_close?(trade)
            symbol_balance.close(trade.quantity)
          else
            symbol_balance << trade
          end
        end

        symbol_balance
      end
    end
  end
end
