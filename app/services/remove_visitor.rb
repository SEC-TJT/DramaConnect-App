# frozen_string_literal: true

module DramaConnect
  # Service to add visitor to project
  class RemoveVisitor
    class VisitorNotRemoved < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, visitor:, dramalist_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .delete("#{api_url}/dramaList/#{dramalist_id}/visitors",
                            json: { email: visitor[:email] })
      puts response
      
      raise VisitorNotRemoved unless response.code == 200
      return response
    end
  end
end
