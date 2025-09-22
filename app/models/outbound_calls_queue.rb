class OutboundCallsQueue < UniqueFIFOQueue
  attr_reader :account

  def initialize(account, **)
    super(key: "account:#{account.id}:outbound_calls", **)
    @account = account
  end

  class << self
    def each_queue(&)
      AppSettings.redis.with do |connection|
        queues = connection.scan_each(match: "*account:*:outbound_calls").each_with_object({}) do |key, result|
          account_id = key.match(/account:([^:]+):outbound_calls/)[1]
          result[account_id] ||= new(Account.find(account_id))
        end

        queues.each_value do |queue|
          yield(queue)
        end
      end
    end
  end
end
