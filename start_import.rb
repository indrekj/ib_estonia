$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'ib_estonia'
require 'exchange_rate_fetcher'
require 'isin_fetcher'

unless ARGV[0]
  puts "Usage: ./start ib-2016.xml ib-2017.xml ..."
  exit 1
end

exchange_rate_fetcher = ExchangeRateFetcher.new
isin_fetcher = IsinFetcher.new

symbols = ARGV.reduce([]) do |acc, path|
  puts ">> Importing #{path} for symbols"
  data = File.read(path)
  acc + IbEstonia::Symbols::Importer.import(data, isin_fetcher)
end

trades = ARGV.reduce([]) do |acc, path|
  puts ">> Importing #{path} for trades"
  data = File.read(path)
  acc + IbEstonia::Trades::Importer.import(data, symbols, exchange_rate_fetcher)
end

dividends = ARGV.reduce([]) do |acc, path|
  puts ">> Importing #{path} for dividends"
  data = File.read(path)
  acc + IbEstonia::Dividends::Importer.import(data, symbols)
end

puts
puts 'Tabel 8.2'
IbEstonia::Trades::TaxReport.new(trades).print

puts
puts 'Tabel 8.8'
IbEstonia::Dividends::TaxReport.new(dividends, exchange_rate_fetcher).print
