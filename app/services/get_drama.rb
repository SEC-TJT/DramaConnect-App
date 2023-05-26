# frozen_string_literal: true

require 'http'

module DramaConnect
  # Returns all projects belonging to an account
  class GetDrama
    def initialize(config)
      @config = config
    end

    def call(user, dramalist_id, drama_id)
      response = HTTP.auth("Bearer #{user.auth_token}")
                    .get("#{@config.API_URL}/dramaList/#{dramalist_id}/dramas/#{drama_id}")

      response.code == 200 ? JSON.parse(response.body.to_s)['data'] : nil
    end
  end
end
