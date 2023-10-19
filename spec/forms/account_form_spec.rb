require "rails_helper"

RSpec.describe AccountForm do
  describe "validations" do
    it "validates the owner's email does not belong to a carrier user" do
      user = create(:user, :carrier, email: "johndoe@example.com")
      form = AccountForm.new(
        carrier: user.carrier,
        owner_name: "John Doe",
        owner_email: "johndoe@example.com"
      )

      expect(form).not_to be_valid
      expect(form.errors[:owner_email]).to be_present
    end

    it "validates the owner's email format" do
      form = AccountForm.new(owner_email: "foobar")

      expect(form).not_to be_valid
      expect(form.errors[:owner_email]).to be_present
    end

    it "validates the calls_per_second" do
      form = AccountForm.new(calls_per_second: 0)

      expect(form).not_to be_valid
      expect(form.errors[:calls_per_second]).to be_present
    end

    it "validates default_tts_voice" do
      form = AccountForm.new(
        default_tts_voice: "Voice.Invalid"
      )

      expect(form).not_to be_valid
      expect(form.errors[:default_tts_voice]).to be_present
    end
  end

  it "has a default value for default_tts_voice" do
    expect(AccountForm.new.default_tts_voice).to be_present
  end

  describe "#save" do
    it "creates an account without an owner" do
      carrier = create(:carrier)
      form = AccountForm.new(
        name: "Rocket Rides",
        enabled: true,
        calls_per_second: 2,
        default_tts_voice: "Basic.Slt"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        access_token: be_present,
        name: "Rocket Rides",
        enabled?: true,
        calls_per_second: 2,
        default_tts_voice: have_attributes(
          identifier: "Basic.Slt"
        )
      )
    end

    it "creates an account with an owner" do
      carrier = create(:carrier)
      form = AccountForm.new(
        name: "Rocket Rides",
        enabled: true,
        owner_name: "John Doe",
        owner_email: "johndoe@example.com",
        default_tts_voice: "Basic.Kal"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        owner: have_attributes(name: "John Doe", email: "johndoe@example.com")
      )
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end

    it "updates an account" do
      carrier = create(:carrier)
      account = create(:account, carrier:, name: "Rocket Rides", default_tts_voice: "Basic.Kal")

      form = AccountForm.new(
        name: "Car Rides",
        default_tts_voice: "Basic.Slt",
        carrier:,
        account:
      )

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        name: "Car Rides",
        default_tts_voice: have_attributes(
          identifier: "Basic.Slt"
        )
      )
    end
  end
end
