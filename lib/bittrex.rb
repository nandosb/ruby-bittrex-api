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
      self
    end


    # Public methods

    def markets()
      request("https://bittrex.com/api/#{API_VERSION}/public/getmarkets")
    end

    def ticker(market)
      request("https://bittrex.com/api/#{API_VERSION}/public/getticker", "market=#{market}")
    end

    def summaries
      request("https://bittrex.com/api/#{API_VERSION}/public/getmarketsummaries")
    end

    def orderbook(market, type, depth = 50)
      request("https://bittrex.com/api/#{API_VERSION}/public/getorderbook", "market=#{market}&type=#{type}&depth=#{depth}")
    end

    def market_history(market, count = 10)
      request("https://bittrex.com/api/#{API_VERSION}/public/getmarkethistory", "market=#{market}&count=#{count}")
    end

    # End of public methods

    # Market actions related methods

    def buy(market, quantity, rate = nil)
      if rate
        request("https://bittrex.com/api/#{API_VERSION}/market/buylimit", "market=#{market}&quantity=#{quantity}&rate=#{rate}")
      else
        request("https://bittrex.com/api/#{API_VERSION}/market/buymarket", "market=#{market}&quantity=#{quantity}")
      end
    end

    def sell(market, quantity, rate = nil)
      if rate
        request("https://bittrex.com/api/#{API_VERSION}/market/selllimit", "market=#{market}&quantity=#{quantity}&rate=#{rate}")
      else
        request("https://bittrex.com/api/#{API_VERSION}/market/sellmarket", "market=#{market}&quantity=#{quantity}")
      end
    end

    def cancel(order_id)
      request("https://bittrex.com/api/#{API_VERSION}/market/cancel", "uuid=#{order_id}")
    end

    def open_orders(market = nil)
      if market then
        request("https://bittrex.com/api/#{API_VERSION}/market/getopenorders", "market=#{market}")
      else
        request("https://bittrex.com/api/#{API_VERSION}/market/getopenorders")
      end
    end

    # End of market actions related methods


    # Personal account methods

    def balance(currency = nil)
      if currency then
        request("https://bittrex.com/api/#{API_VERSION}/account/getbalance", "currency=#{currency}")
      else
        request("https://bittrex.com/api/#{API_VERSION}/account/getbalance")
      end

    end

    def order_history(market = nil, count = 10)
      params = market ? "market=#{market}&count=#{count}" : "count=#{count}"
      request("https://bittrex.com/api/#{API_VERSION}/account/getorderhistory", params)
    end

    # End of personal account methods

    private

      def generate_sign(url, params)
        nonce = Time.now.to_i

        @final_url = "#{url}?apikey=#{@api_key}&nonce=#{nonce}"
        if !params then
          @final_url += '&'+params
        end

        OpenSSL::HMAC.hexdigest(digest = OpenSSL::Digest.new('sha512'), @api_secret, @final_url)
      end

      def handle_response(req)
        response = JSON.load(req)
        if response['success']
          response['result']
        else
          raise Exception, "Request failed: #{response}"
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
