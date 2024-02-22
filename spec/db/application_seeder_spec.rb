require "rails_helper"
require Rails.root.join("db/application_seeder")

describe ApplicationSeeder do
  it "seeds the database" do
    ApplicationSeeder.new.seed!

    expect(Carrier.count).to eq(1)
    expect(User.count).to eq(2)
    expect(Account.carrier_managed.count).to eq(1)
    expect(Account.customer_managed.count).to eq(1)
    expect(ErrorLogNotification.count).to eq(2)
    expect(PhoneNumber.count).to eq(1)

    Account.all.each do |account|
      expect(account).to have_attributes(
        auth_token: be_present,
        default_tts_voice: be_present
      )
    end

    expect(PhoneNumber.first.configuration).to be_present
  end

  it "behaves idempotently" do
    seeder = ApplicationSeeder.new

    2.times { seeder.seed! }

    expect(Carrier.count).to eq(1)
    expect(User.count).to eq(2)
    expect(Account.carrier_managed.count).to eq(1)
    expect(Account.customer_managed.count).to eq(1)
    expect(PhoneNumber.count).to eq(1)
    expect(ErrorLogNotification.count).to eq(2)
  end
end
