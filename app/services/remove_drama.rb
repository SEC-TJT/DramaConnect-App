# frozen_string_literal: true

module DramaConnect
  # Service to remove drama
  class RemoveDrama
    class DramaNotRemoved < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, dramalist_id:, drama_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .delete("#{api_url}/dramaList/#{dramalist_id}/dramas/#{drama_id}")

      
      return JSON.parse(response.to_s) if response.code == 200
      raise DramaNotRemoved unless response.code == 200
      # puts response
      # response
    end
  end
end
