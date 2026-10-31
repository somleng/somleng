class OriginatorIDBehavior
  attr_reader :strategy

  def initialize(strategy)
    super()
    @strategy = strategy
  end

  def resolve(client_id:, managed_id:)
    case
    when strategy.passthrough?
      client_id
    when strategy.fallback?
      client_id.blank? ? managed_id : client_id
    when strategy.override?
      managed_id
    end
  end
end
