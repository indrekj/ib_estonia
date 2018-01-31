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
    tax_records = generate([
      generate_long_trade(
        symbol: {ticker: 'MSFT', description: 'Microsoft Corporation'},
        date: '20110319',
        quantity: 100,
        price: to_eur(BigDecimal('24.86'), 1.413),
        commission: to_eur(BigDecimal('22.29'), 1.413)
      ),
      generate_long_trade(
        symbol: {ticker: 'MSFT', description: 'Microsoft Corporation'},
        date: '20110326',
        quantity: 200,
        price: to_eur(BigDecimal('24.50'), 1.4114),
        commission: to_eur(BigDecimal('29.53'), 1.4114)
      ),
      generate_short_trade(
        symbol: {ticker: 'MSFT', description: 'Microsoft Corporation'},
        date: '20111104',
        quantity: 150,
        price: to_eur(BigDecimal('28.08'), 1.3773),
        commission: to_eur(BigDecimal('27.47'), 1.3773)
      )
    ])

    expect(tax_records.count).to eq(1)
    expect(tax_records[0][0]).to eq('MSFT: Microsoft Corporation')
    expect(tax_records[0][1]).to eq('aktsia')
    expect(tax_records[0][2]).to eq(150)
    expect(tax_records[0][3]).to eq('2011-11-04')
    expect(tax_records[0][4]).to eq('TODO: country') # USA
    expect(tax_records[0][5]).to eq('2648.32') # LHV had 2648.25
    expect(tax_records[0][6]).to eq('19.94')   # LhV had 19.95
    expect(tax_records[0][7]).to eq('3058.16')
  end

  def generate(trades)
    records = IbEstonia::TaxReport.new(trades).generate_tax_records
    IbEstonia::EmtaFormatter.format(records)
  end

  def to_eur(amount, rate)
    amount / rate
  end
end
