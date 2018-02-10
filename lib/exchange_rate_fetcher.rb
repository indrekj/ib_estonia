require 'httparty'

class ExchangeRateFetcher
  def initialize
    @cache_path = File.dirname(__FILE__) + "/../rate_cache"
    @cache =
      if File.exists?(@cache_path)
        JSON.parse(File.read(@cache_path))
      else
        {}
      end
  end

  def convert(amount:, from:, to:, date:)
    rate = fetch_rate(from, to, date)
    amount * rate
  end

  def fetch_rate(from, to, date)
    date = date.strftime("%Y-%m-%d")

    @cache[date] ||= {}
    @cache[date][from] ||= {}

    if rate = @cache[date][from][to]
      rate
    else
      rate = fetch_from_api(from, to, date)
      @cache[date][from][to] = rate
      save_cache
      rate
    end
  end

  def fetch_from_api(from, to, date)
    puts ">>> Fetching #{from}#{to} rate for #{date}"
    response = HTTParty.get("https://api.fixer.io/#{date}?base=#{from}&symbols=#{to}")
    response.parsed_response['rates'][to]
  end

  def save_cache
    File.open(@cache_path, 'w+') do |file|
      file.write(JSON.dump(@cache))
    end
  end
end
