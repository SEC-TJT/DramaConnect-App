# frozen_string_literal: true

require 'http'

module DramaConnect
  class CreateAccount
    # class InvalidAccount < StandardError;end
    # Error for accounts that cannot be created
    class InvalidAccount < StandardError
      def message = 'This account can no longer be created: please start again'
    end

    def initialize(config)
      @config = config
    end

    def call(username:,name:, password:, email:)
      message = {
        email: ,
        username: ,
        name: ,
        password: ,
      }
      puts "#{@config.API_URL}/accounts"
      response = HTTP.post("#{@config.API_URL}/accounts", json: message)

      raise InvalidAccount unless response.code == 201
    end
  end
end
