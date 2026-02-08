require "rails_helper"

RSpec.describe AccountBillingPolicy do
  it "handles accounts with disabled billing" do
    carrier = create(:carrier)
    account = create(:account, billing_enabled: false, carrier:)
    policy = AccountBillingPolicy.new

    result = policy.valid?(interaction: create(:message, account:))

    expect(result).to be_truthy
  end

  it "handles accounts with missing subscriptions" do
    carrier = create(:carrier)
    account = create(:account, :billing_enabled, carrier:)
    policy = AccountBillingPolicy.new

    result = policy.valid?(interaction: create(:message, account:))

    expect(result).to be_falsey
    expect(policy.error_code).to eq(:subscription_disabled)
  end

  it "handles blocked destinations" do
    carrier = create(:carrier)
    account = create(:account, :billing_enabled, carrier:)
    create(:tariff_plan_subscription, plan_category: :outbound_messages, account:)

    policy = AccountBillingPolicy.new

    result = policy.valid?(interaction: create(:message, account:))

    expect(result).to be_falsey
    expect(policy.error_code).to eq(:destination_blocked)
  end

  it "handles insufficient balances" do
    carrier = create(:carrier)
    account = create(:account, :billing_enabled, carrier:)
    tariff_plan = create(:tariff_plan, :outbound_messages, carrier:)
    tariff_schedule = create(:tariff_schedule, category: tariff_plan.category, carrier:)
    create(:tariff_plan_tier, plan: tariff_plan, schedule: tariff_schedule)
    create(
      :destination_tariff,
      schedule: tariff_schedule,
      destination_group: create(:destination_group, carrier:, prefixes: [ "855" ])
    )
    message = create(:message, direction: :outbound_api, account:, to: "855715100999")
    create(:tariff_plan_subscription, plan: tariff_plan, account:)
    policy = AccountBillingPolicy.new(
      credit_validator: instance_spy(RatingEngineClient, sufficient_balance?: false)
    )

    result = policy.valid?(interaction: message)

    expect(result).to be_falsey
    expect(policy.error_code).to eq(:insufficient_balance)
    expect(policy.credit_validator).to have_received(:sufficient_balance?).with(message)
  end
end
