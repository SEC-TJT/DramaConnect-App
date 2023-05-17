# frozen_string_literal: true

require 'roda'
require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/
        routing.get String do |username|
          # if @current_account && @current_account['username'] == username

          if @current_account && @current_account.username == username
            drama_lists = GetAllDramalists.new(App.config).call(@current_account)
            print drama_lists
            view :account, locals: { current_account: @current_account ,drama_lists:  }
          else
            routing.redirect '/auth/login'
          end
        end
        # POST /account/<registration_token>
        routing.post String do |registration_token|
        raise 'Passwords do not match or empty' if
          routing.params['password'].empty? ||
          routing.params['password'] != routing.params['password_confirm']

        new_account = SecureMessage.decrypt(registration_token)
        CreateAccount.new(App.config).call(
          email: new_account['email'],
          username: new_account['username'],
          name: new_account['name'],
          password: routing.params['password']
        )
        flash[:notice] = 'Account created! Please login'
        routing.redirect '/auth/login'
      rescue CreateAccount::InvalidAccount => e
        flash[:error] = e.message
        routing.redirect '/auth/register'
      rescue StandardError => e
        flash[:error] = e.message
        routing.redirect(
          "#{App.config.APP_URL}/auth/register/#{registration_token}"
        )
      end
    end
   end
  end
end
