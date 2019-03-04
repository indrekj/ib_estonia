require 'json'
require 'httparty'

class IsinFetcher
  ENDPOINT = 'http://localhost:7633'

  def initialize
    @cache_path = File.dirname(__FILE__) + "/../isin_cache"
    @cache =
      if File.exists?(@cache_path)
        JSON.parse(File.read(@cache_path))
      else
        {}
      end
  end

  def fetch(contract_id)
    if isin = @cache[contract_id]
      isin
    else
      isin = fetch_from_api(contract_id)
      @cache[contract_id] = isin
      save_cache
      isin
    end
  end

  private

  def fetch_from_api(contract_id)
    puts ">>> Fetching ISIN for Contract ##{contract_id}"
    response = HTTParty.get("#{ENDPOINT}/?contract_id=#{contract_id}")
    if response.code == 200
      response.body
    else
      puts ">>> ISIN provider returned code #{response.code}"
      nil
    end
  rescue Errno::ECONNREFUSED
    puts ">>> Could not connect with #{ENDPOINT}"
    nil
  end

  def save_cache
    File.open(@cache_path, 'w+') do |file|
      file.write(JSON.dump(@cache))
    end
  end
end
