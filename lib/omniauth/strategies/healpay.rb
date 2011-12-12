#require 'omniauth/oauth'
require 'omniauth/strategies/oauth2'
require 'multi_json'

module OmniAuth
  module Strategies
    class Healpay < OmniAuth::Strategies::OAuth2
      #def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
      #  client_options = {
      #    :site =>  "http://gate.healpay.com",
      #    :authorize_url => "http://gate.healpay.com/oauth/healpay/authorize",
      #    :access_token_url => "http://gate.healpay.com/oauth/healpay/access_token"
      #  }
      #  super(app, :healpay_id, api_key, secret_key, client_options, &block)
      #end
      
      option :client_options, {
        :site => "http://gate.healpay.com",
        :authorize_url => "http://gate.healpay.com/oauth/authorize",
        :token_url => "http://gate.healpay.com/oauth/access_token"
      }

      def request_phase
        super
      end

      uid { raw_info['id'] }

      info do
        {
          'first_name' => raw_info['first_name'],
          'last_name' => raw_info['last_name'],
          'email' => raw_info['email']
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('/user').parsed
      end
 
    end
  end
end
