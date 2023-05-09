# frozen_string_literal: true

require 'roda'
require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          
          account = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )

          session[:current_account] = account
          flash[:notice] = "Welcome back #{account['username']}!"
          routing.redirect "/account/#{account['username']}"
        rescue StandardError
          print App.config.API_HOST
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 400
          view :login
        end
      end

      routing.on 'logout' do
        routing.get do
          session[:current_account] = nil
          routing.redirect @login_route
        end
      end
      @register_route = '/auth/register'
      routing.is 'register' do
        routing.get do
          view:register
        end
        routing.post do
          account_data = routing.params.transform_keys(&:to_sym)
          print account_data
          print App.config.API_HOST
          CreateAccount.new(App.config).call(**account_data)
          flash[:notice] = 'Please login with your new account information'
          routing.redirect @login_route
        rescue StandardError => e
          App.logger.info "FAILED to create account: #{e.inspect}"
          App.logger.error e.backtrace
          flash[:error] = 'Failed to create account'
          routing.redirect @register_route
        end
      end
    end
  end
end
