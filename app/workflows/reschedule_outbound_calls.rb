class RescheduleOutboundCalls < ApplicationWorkflow
  def call
    PhoneCall.queued.where(created_at: ..30.minutes.ago).find_each do |phone_call|
      ExecuteWorkflowJob.perform_later(ScheduleOutboundCall.to_s, phone_call)
    end
  end
end
