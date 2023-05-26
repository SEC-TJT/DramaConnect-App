# frozen_string_literal: true

require 'roda'

module DramaConnect
  # Web controller for DramaConnect API
  class App < Roda
    route('dramas') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      # GET /dramas/[dra_id]
      routing.get(String) do |dra_id|
        dra_info = GetDrama.new(App.config)
                              .call(@current_account, dra_id)
        drama = Drama.new(dra_info)

        view :drama, locals: {
          current_account: @current_account, drama: drama
        }
      end
    end
  end
end
