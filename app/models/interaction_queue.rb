class InteractionQueue
  attr_reader :account, :queue

  def initialize(account, **options)
    @account = account
    @queue = options.fetch(:queue) do
      SimpleQueue.new(
        queue_key: options.fetch(:queue_key) { "queue:#{account.id}:#{options.fetch(:interaction_type)}" },
        tmp_queue_key: options.fetch(:queue_key) { "tmp_queue:#{account.id}:#{options.fetch(:interaction_type)}" },
        **options
      )
    end
  end

  def enqueue(...)
    queue.enqueue(...)
  end

  def dequeue(...)
    queue.dequeue(...)
  end

  def empty?
    queue.empty?
  end

  def peek
    queue.peek
  end
end
