class ScheduleOutboundCall < ApplicationWorkflow
  attr_reader :phone_call, :queue

  def initialize(phone_call, **options)
    super()
    @phone_call = phone_call
    @queue = options.fetch(:queue) { InteractionQueue.new(account, interaction_type: :outbound_calls) }
  end

  def call
    queue.enqueue(phone_call.id)
    OutboundCallJob.perform_later(account)
  end

  private

  def account
    phone_call.account
  end
end
