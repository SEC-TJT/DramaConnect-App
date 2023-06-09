# frozen_string_literal: true

require 'roda'
require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class App < Roda
    route('account') do |routing|
      routing.on do
        # GET /account/[username]
        routing.get String do |username|
          account = GetAccountDetails.new(App.config).call(
            @current_account, username
          )
          view :account, locals: { account: account}
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/login'
        end
        # POST /assount/update/[username]
        routing.on 'update' do
          routing.post String do |username|
            task = UpdateAccount.new(App.config).call(
              current_account: @current_account,
              username: username,
              account_data: routing.params
            )
            flash[:notice] = task.to_h['message']
          rescue StandardError
            flash[:error] = 'Could not modify account data'
          ensure
            routing.redirect "/account/#{username}"
          end
        end
        # POST /account/<registration_token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.new.call(routing.params)
          raise Form.message_values(passwords) if passwords.failure?

          new_account = SecureMessage.decrypt(registration_token)
          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            name: new_account['name'],
            password: passwords['password']
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
