require "rails_helper"

RSpec.describe UpdateMessageStatus do
  it "updates a message status" do
    message = create(:message, :queued, :with_status_callback_url)

    UpdateMessageStatus.new(message).call { message.mark_as_sending! }

    expect(message).to have_attributes(
      status: "sending"
    )
    expect(ExecuteWorkflowJob).not_to have_been_enqueued
  end

  it "enqueues a status callback for approved statuses" do
    message = create(:message, :sending, :with_status_callback_url)

    UpdateMessageStatus.new(message).call { message.mark_as_sent! }

    expect(message).to have_attributes(
      status: "sent"
    )
    expect(ExecuteWorkflowJob).to have_been_enqueued.with(
      TwilioAPI::NotifyWebhook.to_s,
      account: message.account,
      url: message.status_callback_url,
      http_method: "POST",
      params: be_present
    )
  end

  it "redacts internal messages" do
    message = create(:message, :sending, :internal, body: "Your OTP code is: 8888")

    UpdateMessageStatus.new(message).call { message.mark_as_sent! }

    expect(message).to have_attributes(
      status: "sent",
      body: ""
    )
  end

  it "does not redact incomplete internal messages" do
    message = create(:message, :queued, :internal, body: "Your OTP code is: 8888")

    UpdateMessageStatus.new(message).call { message.mark_as_sending! }

    expect(message).to have_attributes(
      status: "sending",
      body: message.body
    )
  end
end
