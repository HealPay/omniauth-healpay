require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Healpay < OAuth2
      def initialize(app, api_key = nil, secret_key = nil, options = {}, &block)
        client_options = {
          :site =>  CUSTOM_PROVIDER_URL,
          :authorize_url => "#{CUSTOM_PROVIDER_URL}/oauth/healpay/authorize",
          :access_token_url => "#{CUSTOM_PROVIDER_URL}/oauth/healpay/access_token"
        }
        super(app, :healpay_id, api_key, secret_key, client_options, &block)
      end
      
      protected
      
      def user_data
        @data ||= MultiJson.decode(@access_token.get("/oauth/healpay_id/user.json"))
      end
      
      def request_phase
        options[:scope] ||= "read"
        super
      end
      
      def user_hash
        user_data
      end
      
      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
                                     'uid' => user_data["uid"],
                                     'user' => user_data['user']
                                   })
      end
    end
  end
end
