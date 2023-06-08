# frozen_string_literal: true

require 'http'

module DramaConnect
  # Returns an authenticated user, or nil
  class AuthenticateAccount
    class NotAuthenticatedError < StandardError; end
    class ApiServerError < StandardError; end
    # def initialize(config)
    #   @config = config
    # end

    def call(username:, password:)
      credentials = { username: username, password: password }

      response = HTTP.post("#{ENV['API_URL']}/auth/authenticate",
                           json: SignedMessage.sign(credentials))

      raise(NotAuthenticatedError) if response.code == 401
      raise(ApiServerError) if response.code != 200

      puts JSON.parse(response.to_s)['data']
      account_info = JSON.parse(response.to_s)['data']['attributes']

      { account: account_info['account'],
        auth_token: account_info['auth_token'] }
    rescue HTTP::ConnectionError
      raise ApiServerError
    end
  end
end
