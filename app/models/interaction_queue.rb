class InteractionQueue < SimpleQueue
  attr_reader :account, :interaction_type

  def initialize(account, interaction_type:, **)
    super(**)
    @account = account
    @interaction_type = interaction_type
  end

  def enqueue(interaction_id)
    super(key, interaction_id)
  end

  def dequeue
    super(key)
  end

  def peek
    super(key)
  end

  private

  def key
    "#{account.id}:#{interaction_type}"
  end
end
