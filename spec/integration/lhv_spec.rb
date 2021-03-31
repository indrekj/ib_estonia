require 'spec_helper'

# Uses https://www.lhv.ee/images/docs/LHV_maksuaruanne.pdf to verify different
# use cases.
#
# There's few cent difference because we convert to euros immediately but LHV
# does it after calculating open_amount/etc. This however should be fine
# because we use a 5 decimal place exchange rate and round it only when
# formatting already calculated tax records.
describe 'LHV' do
  it 'tests selling stocks in multiple chunks' do
    symbol = {
      name: 'MSFT',
      description: 'Microsoft Corporation',
      isin: 'US5949181045'
    }
    tax_records = generate([
      buy_stock(
        symbol: symbol,
        date: '20110319',
        quantity: 100,
        price: to_eur(BigDecimal('24.86'), 1.413),
        commission: to_eur(BigDecimal('22.29'), 1.413)
      ),
      buy_stock(
        symbol: symbol,
        date: '20110326',
        quantity: 200,
        price: to_eur(BigDecimal('24.50'), 1.4114),
        commission: to_eur(BigDecimal('29.53'), 1.4114)
      ),
      sell_stock(
        symbol: symbol,
        date: '20111104',
        quantity: 150,
        price: to_eur(BigDecimal('28.08'), 1.3773),
        commission: to_eur(BigDecimal('27.47'), 1.3773)
      )
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('US5949181045')
    expect(tax_records[0][1]).to eq('MSFT: Microsoft Corporation')
    expect(tax_records[0][2]).to eq('aktsia')
    expect(tax_records[0][3]).to eq(150)
    expect(tax_records[0][4]).to eq('04.11.2011')
    expect(tax_records[0][5]).to eq('US') # LHV has USA, but should be fine
    expect(tax_records[0][6]).to eq('2648.32') # LHV had 2648.25
    expect(tax_records[0][7]).to eq('19.94')   # LhV had 19.95
    expect(tax_records[0][8]).to eq('3058.16')
  end

  it 'tests exercising call option' do
    tax_records = generate([
      buy_call(
        symbol: {
          name: 'CBMWAUG117200',
          description: 'BMW call Aug 2011 72',
          isin: 'US123'
        },
        date: '20110801',
        quantity: 4,
        multiplier: 100,
        strike: BigDecimal('50.0'),
        price: BigDecimal('1.9'),
        commission: BigDecimal('16.0')
      ),
      sell_call(
        symbol: {
          name: 'CBMWAUG117200',
          description: 'BMW call Aug 2011 72',
          isin: 'US123'
        },
        date: '20110802',
        quantity: 2,
        multiplier: 100,
        strike: BigDecimal('50.0'),
        price: BigDecimal('2.0'),
        commission: BigDecimal('8.0')
      )
      # TODO: rest of the trade
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('US123')
    expect(tax_records[0][1]).to eq('CBMWAUG117200: BMW call Aug 2011 72')
    expect(tax_records[0][2]).to eq('optsioon')
    expect(tax_records[0][3]).to eq(2)
    expect(tax_records[0][4]).to eq('02.08.2011')
    expect(tax_records[0][5]).to eq('US') # LHV has USA, but should be fine
    expect(tax_records[0][6]).to eq('388.00')
    expect(tax_records[0][7]).to eq('8.00')
    expect(tax_records[0][8]).to eq('400.00')
  end


  def generate(trades)
    records = IbEstonia::Trades::TaxReport.new(trades).generate_tax_records
    IbEstonia::Trades::EmtaFormatter.format(records)
  end

  def to_eur(amount, rate)
    amount / rate
  end
end
