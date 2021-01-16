module Services
  class PhoneCallSerializer < ResourceSerializer
    def serializable_hash(_options = nil)
      super.merge(
        voice_url: object.voice_url,
        voice_method: object.voice_method,
        status_callback_url: object.status_callback_url,
        status_callback_method: object.status_callback_method,
        to: object.to,
        from: object.from,
        sid: object.id,
        account_sid: object.account.id,
        account_auth_token: object.account.auth_token,
        direction: object.direction
      )
    end
  end
end
