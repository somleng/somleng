class OutboundCallJob < ActiveJob::Base
  queue_as(Rails.application.secrets[:active_job_outbound_call_queue])
end
