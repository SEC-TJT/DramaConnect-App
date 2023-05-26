# frozen_string_literal: true

require 'http'

module DramaConnect
  # Create a new configuration file for a drama
  class CreateNewDrama
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, dramalist_id:, drama_data:)
      config_url = "#{api_url}/dramaList/#{dramalist_id}/dramas"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .post(config_url, json: drama_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
