# frozen_string_literal: true

module DramaConnect
  # Service to update drama
  class UpdateDrama
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:,list_id:, drama_id:, drama_data:)
      config_url = "#{api_url}/dramaList/#{list_id}/dramas/#{drama_id}/update"
      puts config_url
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .post(config_url, json: drama_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
