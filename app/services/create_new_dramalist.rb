# frozen_string_literal: true

require 'http'

module DramaConnect
  # Create a new configuration file for a Dramalist
  class CreateNewDramalist
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, dramalist_data:)
      config_url = "#{api_url}/dramaList"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .post(config_url, json: dramalist_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
