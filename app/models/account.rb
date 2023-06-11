# frozen_string_literal: true

module DramaConnect
  class Account
    def initialize(account_info, auth_token = nil)
      @account_info = account_info
      @auth_token = auth_token
    end

    attr_reader :account_info, :auth_token

    def username
      @account_info ? @account_info['attributes']['username'] : nil
    end

    def email
      @account_info ? @account_info['attributes']['email'] : nil
    end

    def avatar
      @account_info ? @account_info['attributes']['avatar'] : nil
    end

    def description
      @account_info ? @account_info['attributes']['description'] : nil
    end

    def logged_out?
      @account_info.nil?
    end

    def logged_in?
      !logged_out?
    end
  end
end
