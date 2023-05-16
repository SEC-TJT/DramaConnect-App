require_relative './account'

module DramaConnect
  class CurrentSession
     def initialize(session)
        @secure_session = SecureSession.new(session)
      end
      def current_account
        Account.new(@secure_session.get[:current_account],@secure_session.get[:auth_token]);
      end
      def current_account=
        @secure_session.set(:current_account,account_info)
        @secure_session.set(:auth_token,auth_token)
      end
      def delete
        @secure_session.delete(:account)
        @secure_session.delete(:auth_token)
      end
      end

end
