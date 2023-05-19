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

          account_info = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )
          current_account = Account.new(account_info['account'],account_info['auth_token'])
          # SecureSession.new(session).set(:current_account, account)
          CurrentSession.new(session).current_account = current_account
          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect "/account/#{current_account.username}"
        rescue AuthenticateAccount::UnauthorizedError
          print App.config.API_HOST
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 401
          view :login
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end
      @logout_route = '/auth/logout'
      # routing.on 'logout' do
      routing.is 'logout' do
        # GET /auth/logout
        routing.get do
          # SecureSession.new(session).delete(:current_account)
          CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      # routing.is 'register' do
      #   routing.get do
      #     view:register
      #   end
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end
        # routing.post do
        #   account_data = routing.params.transform_keys(&:to_sym)
        #   CreateAccount.new(App.config).call(**account_data)
          # POST /auth/register
          routing.post do
            account_data = routing.params.transform_keys(&:to_sym)
            VerifyRegistration.new(App.config).call(account_data)
        #   flash[:notice] = 'Please login with your new account information'
        #   routing.redirect @login_route
        # rescue StandardError => e
        #   App.logger.info "FAILED to create account: #{e.inspect}"
        #   App.logger.error e.backtrace
        #   flash[:error] = 'Failed to create account'
        #   routing.redirect @register_route
            flash[:notice] = 'Please check your email for a verification link'
            routing.redirect '/'
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Our servers are not responding -- please try later'
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.error "Could not process registration: #{e.inspect}"
            flash[:error] = 'Registration process failed -- please try later'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please choose a new password'
          new_account = SecureMessage.decrypt(registration_token)
          view :register_confirm,
              locals: { new_account:,
                        registration_token: }
        end
      end
    end
  end
end
