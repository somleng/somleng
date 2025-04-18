require "rails_helper"

RSpec.describe ScheduleOutboundCall do
  it "schedules an outbound call" do
    account = create(:account)
    phone_call = create(:phone_call, account:)
    account_queue = build_queue(account)

    ScheduleOutboundCall.call(phone_call, queue: account_queue)

    expect(account_queue.peek).to eq(phone_call.id)
    expect(OutboundCallJob).to have_been_enqueued.with(account)
  end

  def build_queue(account, **options)
    options = {
      interaction_type: :outbound_calls,
      **options
    }
    InteractionQueue.new(account, **options)
  end
end
