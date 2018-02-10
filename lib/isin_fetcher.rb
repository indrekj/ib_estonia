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

  def fetch(symbol_name)
    if isin = @cache[symbol_name]
      isin
    else
      isin = fetch_from_api(symbol_name)
      @cache[symbol_name] = isin
      save_cache
      isin
    end
  end

  private

  def fetch_from_api(symbol_name)
    puts ">>> Fetching ISIN for #{symbol_name}"
    response = HTTParty.get("#{ENDPOINT}/?symbol=#{symbol_name}")
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
