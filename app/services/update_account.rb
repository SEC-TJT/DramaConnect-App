# frozen_string_literal: true

module DramaConnect
  # Service to update drama
  class UpdateAccount
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:,username:, account_data:)
      config_url = "#{api_url}/accounts/#{username}/update"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .post(config_url, json: account_data)
      response.code == 200 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
