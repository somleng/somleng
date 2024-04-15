require "rails_helper"

RSpec.describe EndCallJob do
  it "ends a call" do
    phone_call = create(:phone_call, :outbound, :answered, external_id: "phone-call-external-id")
    stub_request(:delete, %r{https://switch.internal.somleng.org}).to_return(status: 204)

    EndCallJob.perform_now(phone_call)

    expect(WebMock).to have_requested(:delete, "https://switch.internal.somleng.org/calls/phone-call-external-id")
  end

  it "doesn't attempt to end a queued call" do
    phone_call = create(:phone_call, :queued)

    EndCallJob.perform_now(phone_call)

    expect(WebMock).not_to have_requested(:delete, %r{https://switch.internal.somleng.org})
  end

  it "retries failed attempts" do
    phone_call = create(:phone_call, :outbound, :answered, external_id: "phone-call-external-id")
    stub_request(:delete, %r{https://switch.internal.somleng.org}).to_return(status: 500)

    expect {
      EndCallJob.perform_now(phone_call)
    }.to raise_error(EndCallJob::RetryJob)

    expect(WebMock).to have_requested(:delete, "https://switch.internal.somleng.org/calls/phone-call-external-id")
  end
end
