class OutboundCallsQueue < SimpleQueue
  def initialize(account, **)
    super(key: "account:#{account.id}:outbound_calls", **)
  end
end
