require 'http'

module DramaConnect
  class GetAllAccounts
    def initialize(config)
      @config = config
    end

    def call(current_account)

      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/accounts")
      accounts_data = JSON.parse(response.to_s)['data']

      result = accounts_data.reject { |account| account["attributes"]["username"] == current_account.username}
               .map { |account| { "username" => account["attributes"]["username"], "email" => account["attributes"]["email"] } }

      response.code == 200?result:nil

    end

  end
end
