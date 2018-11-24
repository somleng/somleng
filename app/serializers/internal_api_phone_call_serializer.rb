class InternalApiPhoneCallSerializer < AbstractPhoneCallSerializer
  attributes :account_auth_token, :account_sid, :api_version, :direction,
             :from, :routing_instructions, :sid, :to, :voice_url, :voice_method

  def account_auth_token
    serializable.account.auth_token
  end

  def routing_instructions
    call_router.routing_instructions
  end

  private

  def call_router
    CallRouter.new(
      source: serializable.from,
      destination: serializable.to,
      source_matcher: serializable.account.source_matcher
    )
  end
end
