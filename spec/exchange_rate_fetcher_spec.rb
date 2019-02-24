require 'spec_helper'
require 'exchange_rate_fetcher'

RSpec.describe ExchangeRateFetcher do
  let(:fetcher) { described_class.new(xml_db) }
  let(:xml_db) { read_fixture('eurofxref-hist.xml') }
  let(:existing_date) { Time.local(2019, 2, 22, 15, 00) }

  it 'converts currency from USD to EUR' do
    amount = BigDecimal('5.3')
    expect(fetcher.convert(amount: 5.3, from: 'USD', to: 'EUR', date: existing_date))
      .to eq(amount / 1.1325)
  end

  it 'converts currency from USD to EUR using the closest date' do
    amount = BigDecimal('5.3')
    date = existing_date.to_date.next_day
    expect(fetcher.convert(amount: amount, from: 'USD', to: 'EUR', date: date))
      .to eq(amount / 1.1325)
  end

  it 'converts with rate 1.0 when both currencies are the same' do
    expect(fetcher.convert(amount: 6.5, from: 'EUR', to: 'EUR', date: existing_date))
      .to eq(6.5)
  end
end
