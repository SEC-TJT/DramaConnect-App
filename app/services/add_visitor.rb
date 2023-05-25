# frozen_string_literal: true

module DramaConnect
  # Service to add visitor to dramaList
  class AddVisitor
    class CollaboratorNotAdded < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, visitor:, dramaList_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                    .put("#{api_url}/dramaLists/#{dramaList_id}/visitors",
                          json: { email: visitor[:email] })

      raise CollaboratorNotAdded unless response.code == 200
    end
  end
end
