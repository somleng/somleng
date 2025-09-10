class OutboundCallsQueue < UniqueFIFOQueue
  attr_reader :account

  def initialize(account, **)
    super(key: "account:#{account.id}:outbound_calls", **)
    @account = account
  end

  class << self
    def each_queue(&)
      AppSettings.redis.with do
        _1.scan_each(match: "account:*:outbound_calls") do |key|
          queue = new(Account.find(key.split(":")[1]))
          yield(queue)
        end
      end
    end
  end
end
