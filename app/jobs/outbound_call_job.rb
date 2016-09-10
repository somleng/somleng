require "twilreapi/worker/job/outbound_call_job"

class OutboundCallJob < ActiveJob::Base
  def perform(payload)
    phone_call_json = JSON.parse(payload)
    phone_call = PhoneCall.find(phone_call_json["sid"])
    ::Twilreapi::Worker::Job::OutboundCallJob.new.perform(phone_call.to_somleng_json)
  end
end
