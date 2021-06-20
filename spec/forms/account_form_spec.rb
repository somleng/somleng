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

      expect(form).to be_invalid
      expect(form.errors[:owner_email]).to be_present
    end

    it "validates the owner's email format" do
      form = AccountForm.new(owner_email: "foobar")

      expect(form).to be_invalid
      expect(form.errors[:owner_email]).to be_present
    end
  end

  describe "#save" do
    it "creates an account without an owner" do
      carrier = create(:carrier)
      form = AccountForm.new(name: "Rocket Rides", enabled: true)
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        access_token: be_present,
        name: "Rocket Rides",
        enabled?: true
      )
    end

    it "creates an account with an owner" do
      carrier = create(:carrier)
      form = AccountForm.new(
        name: "Rocket Rides",
        enabled: true,
        owner_name: "John Doe",
        owner_email: "johndoe@example.com"
      )
      form.carrier = carrier

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        owner: have_attributes(name: "John Doe", email: "johndoe@example.com")
      )
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end
  end
end
