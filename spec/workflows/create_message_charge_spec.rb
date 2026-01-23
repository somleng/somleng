require "rails_helper"

RSpec.describe CreateMessageCharge do
  it "creates a message charge" do
    account = create(:account, billing_enabled: true)
    create(:tariff_plan_subscription, account:, category: :outbound_messages)
    message = create(:message, :sending, account:, direction: :outbound)
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

  it "handles accounts without tariff plan subscriptions" do
    account = create(:account, billing_enabled: true)
    message = create(:message, account:)

    expect { CreateMessageCharge.call(message) }.to raise_error(CreateMessageCharge::Error)

    expect(message).to have_attributes(
      error_code: ApplicationError::Errors.fetch(:subscription_disabled).code,
      error_message: ApplicationError::Errors.fetch(:subscription_disabled).message,
      status: "failed"
    )
  end

  it "handles insufficient balance errors" do
    account = create(:account, billing_enabled: true)
    create(:tariff_plan_subscription, account:, category: :outbound_messages)
    message = create(:message, :sending, account:, direction: :outbound)
    rating_engine_client = instance_spy(RatingEngineClient)
    allow(rating_engine_client).to receive(:create_message_charge).and_raise(RatingEngineClient::FailedCDRError.new("Insufficient balance", error_code: :insufficient_balance))

    expect { CreateMessageCharge.call(message, client: rating_engine_client) }.to raise_error(CreateMessageCharge::Error)

    expect(message).to have_attributes(
      error_code: ApplicationError::Errors.fetch(:insufficient_balance).code,
      error_message: ApplicationError::Errors.fetch(:insufficient_balance).message,
      status: "failed"
    )
  end
end
