require "rails_helper"

RSpec.describe CreateMessageCharge do
  it "creates a message charge" do
    account = create(:account, billing_enabled: true)
    create(
      :tariff_plan_subscription,
      account:,
      plan: create(
        :tariff_plan, :configured, :outbound_messages,
        carrier: account.carrier,
        destination_prefixes: [ "855" ]
      )
    )
    message = create(:message, :sending, account:, direction: :outbound, to: "855715100989")
    rating_engine_client = instance_spy(RatingEngineClient)

    CreateMessageCharge.call(message, client: rating_engine_client)

    expect(rating_engine_client).to have_received(:create_message_charge).with(message)
  end

  it "handles accounts with billing disabled" do
    account = create(:account, billing_enabled: false)
    message = create(:message, account:)
    rating_engine_client = instance_spy(RatingEngineClient)

    CreateMessageCharge.call(message, client: rating_engine_client)

    expect(rating_engine_client).not_to have_received(:create_message_charge)
  end

  it "handles accounts with and invalid billing policy" do
    account = create(:account, billing_enabled: true)
    message = create(:message, account:)

    expect { CreateMessageCharge.call(message) }.to raise_error(CreateMessageCharge::Error)

    expect(message).to have_attributes(
      error_code: ApplicationError::Errors.fetch(:subscription_disabled).code,
      error_message: ApplicationError::Errors.fetch(:subscription_disabled).message,
      status: "failed"
    )
  end
end
