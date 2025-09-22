class ScheduleOutboundCall < ApplicationWorkflow
  attr_reader :phone_call, :queue

  def initialize(phone_call, **options)
    super()
    @phone_call = phone_call
    @queue = options.fetch(:queue) { OutboundCallsQueue.new(account) }
  end

  def call
    return unless queue.enqueue(phone_call.id)

    OutboundCallJob.perform_later(account)
  end

  private

  def account
    phone_call.account
  end
end
