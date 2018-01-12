module EmtaFormatters
  # See https://www.emta.ee/sites/default/files/eraklient/tulu-deklareerimine/deklaratsioonide-vormid/2017/tabel_8.2.pdf
  module StockFormatter
    def self.format(tax_records)
      tax_records.map do |tax_record|
        format_record(tax_record)
      end
    end

    def self.format_record(tax_record)
      [
        name(tax_record),
        'aktsia',
        tax_record.quantity,
        tax_record.date.strftime("%Y-%m-%d"),
        country(tax_record),
        Format(tax_record.open_amount),
        "TODO: kulud",
        Format(tax_record.close_amount),
        0
      ]
    end

    def self.name(tax_record)
      symbol = tax_record.symbol

      if tax_record.closing_long?
        "#{symbol.ticker}: #{symbol.description}"
      else
        "#{symbol.ticker}: #{symbol.description}**"
      end
    end

    def self.country(tax_record)
      "TODO: country"
    end
  end
end
