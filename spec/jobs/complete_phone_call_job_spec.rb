require "rails_helper"

RSpec.describe CompletePhoneCallJob do
  it "handles completed calls" do
    phone_call = create(:phone_call, :inbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: Time.current, sip_term_status: "200")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      status: "completed",
      uncompleted?: false,
      interaction: be_present
    )
  end

  it "handles failed inbound calls" do
    phone_call = create(:phone_call, :inbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "200")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      status: "failed",
      uncompleted?: false,
      interaction: be_blank
    )
  end

  it "handles not answered calls" do
    phone_call = create(:phone_call, :outbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "480")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      status: "not_answered",
      uncompleted?: false
    )
  end

  it "handles busy calls" do
    phone_call = create(:phone_call, :outbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "486")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      status: "busy",
      uncompleted?: false
    )
  end

  it "handles failed outbound calls" do
    phone_call = create(:phone_call, :outbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "404")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      status: "failed",
      uncompleted?: false
    )
  end

  it "handles canceled calls" do
    phone_call = create(:phone_call, :outbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_invite_failure_status: "487")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      status: "canceled",
      uncompleted?: false
    )
  end

  it "sends a webhook" do
    phone_call = create(:phone_call, :outbound, :initiated, :with_status_callback_url)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "480")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      "TwilioAPI::NotifyWebhook",
      account: phone_call.account,
      url: phone_call.status_callback_url,
      http_method: phone_call.status_callback_method,
      params: hash_including("CallStatus" => "no-answer")
    ).on_queue(AppSettings.fetch(:aws_sqs_high_priority_queue_name))
  end

  it "retries on invalid state transitions" do
    phone_call = create(:phone_call, :outbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "200")

    2.times.map { Thread.new { CompletePhoneCallJob.perform_now(phone_call) } }.each(&:join)

    expect(CompletePhoneCallJob).to have_been_enqueued
  end

  it "creates an event" do
    phone_call = create(:phone_call, :outbound, :initiated)
    create(:call_data_record, phone_call:, answer_time: nil, sip_term_status: "200")

    CompletePhoneCallJob.perform_now(phone_call)

    expect(phone_call).to have_attributes(
      events: contain_exactly(
        have_attributes(
          type: "phone_call.completed",
          carrier: phone_call.carrier,
        )
      )
    )
  end
end
