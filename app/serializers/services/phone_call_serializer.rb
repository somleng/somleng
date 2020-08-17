module Services
  class PhoneCallSerializer < ApplicationSerializer
    attr_reader :object

    def serializable_hash(_options = nil)
      {
        voice_url: object.voice_url,
        voice_method: object.voice_method,
        to: object.to,
        from: object.from,
        sid: object.id,
        account_sid: object.account.id,
        account_auth_token: object.account.auth_token,
        direction: object.direction,
        api_version: "2010-04-01"
      }
    end
  end
end
