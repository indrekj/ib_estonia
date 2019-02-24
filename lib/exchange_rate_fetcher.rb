require 'nokogiri'
require 'net/http'

class ExchangeRateFetcher
  HISTORICAL_URL = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml'.freeze

  def initialize(xml_db = Net::HTTP.get(URI.parse(HISTORICAL_URL)))
    @db = prepare(xml_db)
  end

  def convert(amount:, from:, to:, date:)
    rate = fetch_rate(from, to, date)
    amount / rate
  end

  private

  def fetch_rate(from, to, date)
    return 1.0 if from == to
    raise 'Exchange rate fetcher works only if target is EUR' if to != 'EUR'

    date = date.to_date if date.is_a?(Time)

    BigDecimal(exchange_rates_for_day(date).fetch(from))
  end

  # Exchange rates are not published for dates that are holidays. In that case
  # the previous rate must be returned.
  def exchange_rates_for_day(date)
    key = date.strftime("%Y-%m-%d")
    return @db.fetch(key) if @db.key?(key)

    exchange_rates_for_day(date.prev_day)
  end

  def prepare(xml_db)
    db = {}

    doc = Nokogiri::XML(xml_db)
    doc.remove_namespaces!
    doc.xpath('Envelope/Cube/Cube[@time]').each do |date_element|
      date = date_element.attr('time')
      db[date] = {}

      date_element.xpath('Cube').each do |currency_element|
        currency = currency_element.attr('currency')
        rate = currency_element.attr('rate')

        db[date][currency] = rate
      end
    end

    db
  end
end
