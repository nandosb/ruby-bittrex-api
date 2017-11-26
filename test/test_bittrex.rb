require 'minitest/autorun'
require 'minitest/byebug' if ENV['DEBUG']
require 'bittrex'

# DEBUG=1 rake test --to run the test suite and debug
class BittrexTest < Minitest::Test

  def setup
    @client = Bittrex.new('<your_api_key>', '<your_api_secret')
  end

  def test_get_markets

    markets = @client.markets()

    assert_equal markets.class, Array

    assert markets.size > 1

  end

  def test_market_data

    markets = @client.markets()

    market = markets.first

    assert market.key?("MarketCurrency")
    assert market.key?("BaseCurrency")
    assert market.key?("MarketCurrencyLong")
    assert market.key?("BaseCurrencyLong")
    assert market.key?("MinTradeSize")
    assert market.key?("MarketName")
    assert market.key?("IsActive")
    assert market.key?("Created")
    assert market.key?("Notice")
    assert market.key?("IsSponsored")
    assert market.key?("LogoUrl")

  end


  # private method: you'll need and API key/secret to test this
  def test_balances

    balances = @client.balances()

    assert_equal balances.class, Array

    assert balances.size > 1

  end


  def test_balance

    balance = @client.balance('BTC')

    assert_equal balance.class, Hash

  end


  def test_buy
    quantity = 0.0005
    unit_price = 1

    order = @client.buy('USDT-BTC',quantity, unit_price)

    assert order.key?("uuid")
  end

  # Make sure you have some founds in your account before to test
  def test_buy_insufficient_founds_exception
    quantity = 10000
    unit_price = 3000

    assert_raises Exception do
      # INSUFFICIENT_FUNDS
      @client.buy('USDT-BTC', quantity, unit_price)
    end
  end

  # Make sure you have some founds in your account before to test
  def test_buy_dust_trade_exception
    quantity = 0.000001
    unit_price = 1

    assert_raises Exception do
      # DUST_TRADE_DISALLOWED_MIN_VALUE_50K_SAT
      @client.buy('USDT-BTC', quantity, unit_price)
    end
  end

  # Make sure you have some founds in your account before to test
  def test_sell
    quantity = 0.0000005
    unit_price = 100000

    order = @client.sell('USDT-BTC',quantity, unit_price)

    assert order.key?("uuid")
  end

  # Make sure you have some founds in your account before to test
  def test_sell_small_price
    quantity = 0.0000005
    unit_price = 100000.123456789
    truncated_price = (unit_price * 100000000).floor / 100000000.0

    order = @client.sell('USDT-BTC',quantity, unit_price)

    assert order.key?("uuid")

    remote_order = @client.open_order(order['uuid'])

    assert_equal remote_order['OrderUuid'], order['uuid']
    refute_equal remote_order['Limit'], unit_price
    assert_equal remote_order['Limit'], truncated_price

  end

  def test_open_order_not_found
    order_id = 'asdf-asdf-asdf'

    order = @client.open_order(order_id)

    assert_nil order

  end

  def test_closed_orders
    orders = @client.order_history('USDT-BTC',2)

    assert_equal orders.size, 2
  end

  def test_market_summary

    market = 'USDT-BTC'

    summary = @client.market_summary(market)

    assert_equal  summary['MarketName'], market
  end

end