# frozen_string_literal: true

module DramaConnect
  # Service to update drama
  class UpdateDramalist
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:,list_id:, dramalist_data:)
      config_url = "#{api_url}/dramaList/#{list_id}/update"
      puts config_url
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .post(config_url, json: dramalist_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
