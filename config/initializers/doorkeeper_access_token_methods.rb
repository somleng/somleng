module Doorkeeper
  module OAuth
    class Token
      class << self
        def from_basic_user_password_authorization(request)
          pattern = /^Basic /i
          header  = request.authorization

          if match?(header, pattern)
            user = token_from_basic_header(header, pattern)
            password = password_from_basic_header(header, pattern)
            AccessToken.find_by(:resource_owner_id => user, :token => password) && password
          end
        end

        private

        def password_from_basic_header(header, pattern)
          encoded_header = token_from_header(header, pattern)
          token, password = decode_basic_credentials(encoded_header)
          password
        end

        def decode_basic_credentials(encoded_header)
          Base64.decode64(encoded_header).split(/:/, 2)
        end
      end
    end
  end
end
