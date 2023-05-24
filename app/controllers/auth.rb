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

          credentials = Form::LoginCredentials.new.call(routing.params)
          puts credentials.to_h

          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end
          puts **credentials.values
          authenticated = AuthenticateAccount.new(App.config)
            .call(**credentials.values)
          puts 'hi2'
          puts "authenticated:",authenticated
          puts 'hi'
          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )
          puts  'hi4'
          puts  current_account.username
          # account_info = AuthenticateAccount.new(App.config).call(
          #   username: routing.params['username'],
          #   password: routing.params['password']
          # )
          # current_account = Account.new(account_info['account'],account_info['auth_token'])
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
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end
          # POST /auth/register
          routing.post do
            
            registration = Form::Registration.new.call(routing.params)
            puts registration.to_h
            
            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end
            
            VerifyRegistration.new(App.config).call(registration.to_h)
            # account_data = routing.params.transform_keys(&:to_sym)
            # VerifyRegistration.new(App.config).call(account_data)
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
