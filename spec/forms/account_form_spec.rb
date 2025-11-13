require "rails_helper"

RSpec.describe AccountForm do
  describe "validations" do
    it "validates the owner does not have a carrier role" do
      user = create(:user, :carrier, email: "johndoe@example.com")
      form = build_form(
        carrier: user.carrier,
        owner_name: "John Doe",
        owner_email: "johndoe@example.com"
      )

      expect(form).not_to be_valid
      expect(form.errors[:owner_email]).to be_present
    end

    it "allows a user to own multiple accounts" do
      user = create(:user, :with_account_membership, email: "johndoe@example.com")
      form = build_form(
        carrier: user.carrier,
        owner_name: "John Doe",
        owner_email: "johndoe@example.com"
      )

      form.valid?

      expect(form.errors[:owner_email]).to be_blank
    end

    it "validates the owner's email format" do
      form = build_form(owner_email: "foobar")

      expect(form).not_to be_valid
      expect(form.errors[:owner_email]).to be_present
    end

    it "validates the calls_per_second" do
      form = build_form(calls_per_second: 0)

      expect(form).not_to be_valid
      expect(form.errors[:calls_per_second]).to be_present
    end

    it "validates default_tts_voice" do
      form = build_form(
        default_tts_voice: "Voice.Invalid"
      )

      expect(form).not_to be_valid
      expect(form.errors[:default_tts_voice]).to be_present
    end
  end

  it "has a default value for default_tts_voice" do
    expect(build_form.default_tts_voice).to be_present
  end

  describe "#save" do
    it "creates an account without an owner" do
      carrier = create(:carrier)
      form = build_form(
        name: "Rocket Rides",
        enabled: true,
        calls_per_second: 2,
        default_tts_voice: "Basic.Slt"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to be_truthy
      expect(form.object).to have_attributes(
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
      form = build_form(
        name: "Rocket Rides",
        enabled: true,
        owner_name: "John Doe",
        owner_email: "johndoe@example.com",
        default_tts_voice: "Basic.Kal"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to be_truthy
      expect(form.object).to have_attributes(
        owner: have_attributes(name: "John Doe", email: "johndoe@example.com")
      )
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end

    it "updates a carrier managed account" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:)
      account = create(
        :account,
        :carrier_managed,
        carrier:,
        sip_trunk:,
        name: "Rocket Rides",
        default_tts_voice: "Basic.Kal"
      )

      form = build_form(
        name: "Car Rides",
        default_tts_voice: "Basic.Slt",
        carrier:,
        object: account
      )

      result = form.save

      expect(result).to be_truthy
      expect(form.object).to have_attributes(
        name: "Car Rides",
        default_tts_voice: have_attributes(
          identifier: "Basic.Slt"
        ),
        sip_trunk: nil
      )
    end

    it "updates a customer managed account" do
      carrier = create(:carrier)
      sip_trunk = create(:sip_trunk, carrier:)
      tariff_plan = create(:tariff_plan, carrier:)
      account = create(
        :account,
        :customer_managed,
        carrier:,
        sip_trunk:,
        calls_per_second: 1,
      )
      tariff_plan_subscription = create(:tariff_plan_subscription, account:)

      form = AccountForm.initialize_with(account)
      form.attributes = {
        sip_trunk_id: nil,
        calls_per_second: 10,
        tariff_plan_subscriptions: {
          plan_id: tariff_plan.id,
          category: tariff_plan_subscription.category,
          id: tariff_plan_subscription.id
        }
      }

      result = form.save

      expect(result).to be_truthy
      expect(form.object).to have_attributes(
        sip_trunk: nil,
        calls_per_second: 10,
        type: "customer_managed"
      )
    end
  end

  def build_form(**params)
    AccountForm.new(carrier: build_stubbed(:carrier), **params)
  end
end
