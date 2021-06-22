require "rails_helper"

RSpec.describe UserForm do
  describe "validations" do
    it "validates the email has not yet been taken" do
      create(:user, email: "johndoe@example.com")

      form = UserForm.new(email: "johndoe@example.com")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end

    it "validates the email format" do
      form = UserForm.new(email: "foobar")

      expect(form).to be_invalid
      expect(form.errors[:email]).to be_present
    end
  end

  describe "#save" do
    it "creates a user" do
      carrier = create(:carrier)
      inviter = create(:user, :carrier, carrier: carrier)
      form = UserForm.new(name: "John Doe", email: "johndoe@example.com", role: "admin")
      form.carrier = carrier
      form.inviter = inviter

      result = form.save

      expect(result).to eq(true)
      expect(form.user).to have_attributes(
        name: "John Doe",
        email: "johndoe@example.com",
        carrier_role: "admin",
        invited_by: inviter
      )
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end
  end
end
