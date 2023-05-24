# frozen_string_literal: true

require 'http'

module DramaConnect
  # Returns all drama belonging to an dramalist
  class GetDramas
    def initialize(config)
      @config = config
    end

    def call(current_account, list_id)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .get("#{@config.API_URL}/dramaList/#{list_id}/dramas")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
