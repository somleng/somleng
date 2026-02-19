require "rails_helper"
require Rails.root.join("db/application_seeder")

describe ApplicationSeeder do
  it "seeds the database" do
    seeder = ApplicationSeeder.new(rating_engine_client: instance_spy(RatingEngineClient))

    seeder.seed!

    expect(Carrier.all).to contain_exactly(
      have_attributes(
        billing_currency: "USD",
        default_tariff_package: be_present
      )
    )
    expect(PhoneCall.all).to contain_exactly(
      have_attributes(
        region: be_present
      )
    )
    expect(User.count).to eq(2)
    expect(Account.carrier_managed.count).to eq(1)
    expect(Account.customer_managed.count).to eq(1)
    expect(ErrorLogNotification.count).to eq(1)
    expect(PhoneNumber.count).to eq(1)
    expect(IncomingPhoneNumber.count).to eq(1)
    expect(PhoneNumberPlan.count).to eq(1)
    expect(SMSGateway.count).to eq(1)
    expect(TariffPackage.count).to eq(1)
    expect(TariffPlanSubscription.count).to eq(4)
    expect(BalanceTransaction.count).to eq(1)

    Account.find_each do |account|
      expect(account).to have_attributes(
        auth_token: be_present,
        default_tts_voice: be_present
      )
    end

    expect(seeder.rating_engine_client).to have_received(:upsert_charging_profile).once
    expect(seeder.rating_engine_client).to have_received(:update_account_balance).once
    expect(seeder.rating_engine_client).to have_received(:upsert_account).once
    expect(seeder.rating_engine_client).to have_received(:upsert_destination_group).once
    expect(seeder.rating_engine_client).to have_received(:upsert_tariff_plan).exactly(4).times
    expect(seeder.rating_engine_client).to have_received(:upsert_tariff_schedule).exactly(4).times
  end

  it "behaves idempotently" do
    stub_rating_engine_request
    seeder = ApplicationSeeder.new

    2.times { seeder.seed! }

    expect(Carrier.count).to eq(1)
    expect(User.count).to eq(2)
    expect(Account.carrier_managed.count).to eq(1)
    expect(Account.customer_managed.count).to eq(1)
    expect(PhoneNumber.count).to eq(1)
    expect(IncomingPhoneNumber.count).to eq(1)
    expect(PhoneNumberPlan.count).to eq(1)
    expect(PhoneCall.count).to eq(1)
    expect(SMSGateway.count).to eq(1)
    expect(ErrorLogNotification.count).to eq(1)
    expect(TariffPackage.count).to eq(1)
    expect(BalanceTransaction.count).to eq(1)
  end
end
