require 'http'

module DramaConnect
  class GetAllDramalists
    def initialize(config)
      @config = config
    end

    def call(current_account)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .get("#{@config.API_URL}/dramaList")

      response.code == 200?JSON.parse(response.to_s)['data']:nil

    end

  end
end
