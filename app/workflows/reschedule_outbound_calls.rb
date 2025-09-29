class RescheduleOutboundCalls < ApplicationWorkflow
  attr_reader :workflow

  def initialize(workflow: ScheduleOutboundCall)
    super()
    @workflow = workflow
  end

  def call
    PhoneCall.queued.where(created_at: ..30.minutes.ago, initiation_queued_at: nil).includes(:account).find_each do |phone_call|
      workflow.call(phone_call)
    end
  end
end
