require "bittrex/version"
require 'openssl'
require 'json'
require 'open-uri'

module Bittrex
  class << self
    API_VERSION = 'v1.1'

    def new(api_key, api_secret)
      @api_key = api_key
      @api_secret = api_secret
      @base_url = "https://bittrex.com/api/#{API_VERSION}"
      self
    end

    # Public methods

    def markets()
      request("#{@base_url}/public/getmarkets")
    end

    def ticker(market)
      request("#{@base_url}/public/getticker", "market=#{market}")
    end

    def market_summaries
      request("#{@base_url}/public/getmarketsummaries")
    end

    def market_summary(market)
      request("#{@base_url}/public/getmarketsummary","market=#{market}")
    end

    def orderbook(market, type, depth = 50)
      request("#{@base_url}/public/getorderbook", "market=#{market}&type=#{type}&depth=#{depth}")
    end

    def market_history(market, count = 10)
      request("#{@base_url}/public/getmarkethistory", "market=#{market}&count=#{count}")
    end

    # End of public methods

    # Market actions related methods

    def buy(market, quantity, rate = nil)
      if rate
        request("#{@base_url}/market/buylimit", "market=#{market}&quantity=#{quantity}&rate=#{rate}")
      else
        request("#{@base_url}/market/buymarket", "market=#{market}&quantity=#{quantity}")
      end
    end

    def sell(market, quantity, rate = nil)
      if rate
        request("#{@base_url}/market/selllimit", "market=#{market}&quantity=#{quantity}&rate=#{rate}")
      else
        request("#{@base_url}/market/sellmarket", "market=#{market}&quantity=#{quantity}")
      end
    end

    def cancel(order_id)
      request("#{@base_url}/market/cancel", "uuid=#{order_id}")
    end

    def open_orders(market = nil)
      if market then
        request("#{@base_url}/market/getopenorders", "market=#{market}")
      else
        request("#{@base_url}/market/getopenorders")
      end
    end

    def open_order(order_uuid, market = nil)
      orders = []

      if market then
        orders = request("#{@base_url}/market/getopenorders", "market=#{market}")
      else
        orders = request("#{@base_url}/market/getopenorders")
      end

      orders.each do |order|
        if order['OrderUuid'] == order_uuid then
          return order
        end
      end

      return nil

    end

    # End of market actions related methods


    # Personal account methods

    def balances()
      request("#{@base_url}/account/getbalances")
    end

    def balance(currency)
      request("#{@base_url}/account/getbalance", "currency=#{currency}")
    end

    def get_order(order_id)
      request("#{@base_url}/account/getorder", "uuid=#{order_id}")
    end


    # Retrieves completed orders.
    # This method use to return the newest first,
    # but there is no guarantee by Bittrex about the order in the response
    def order_history(market = nil, count = 10)
      params = market ? "market=#{market}" : ""
      orders = request("#{@base_url}/account/getorderhistory", params)

      if orders.size > count then
        return orders[0,count]
      end

      return orders
    end

    # End of personal account methods

    private

      def generate_sign(url, params)
        nonce = Time.now.to_i

        @final_url = "#{url}?apikey=#{@api_key}&nonce=#{nonce}"
        if params then
          @final_url += '&'+params
        end

        OpenSSL::HMAC.hexdigest(digest = OpenSSL::Digest.new('sha512'), @api_secret, @final_url)
      end

      def handle_response(req)
        response = JSON.load(req)
        if response['success']
          response['result']
        else
          raise Exception, response['message']
        end
      end

      def request(url, params = nil)
        begin
          hmac_sign = generate_sign(url, params)
          handle_response open(@final_url, 'apisign' => hmac_sign)
        rescue
          return false
        end
      end
  end
end
