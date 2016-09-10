require "twilreapi/worker/job/outbound_call_job"

class OutboundCallJob < ActiveJob::Base
  def perform(payload)
    phone_call_json = JSON.parse(payload)
    phone_call = PhoneCall.find(phone_call_json["sid"])
    outbound_call_id = Twilreapi::Worker::Job::OutboundCallJob.new.perform(phone_call.to_somleng_json)
    phone_call.somleng_call_id = outbound_call_id
    phone_call.initiate_or_cancel!
  end
end
