require "rails_helper"

RSpec.describe CarrierForm do
  describe "validations" do
    it "validates the email has not yet been taken" do
      create(:user, email: "johndoe@example.com")

      form = CarrierForm.new(work_email: "johndoe@example.com")

      expect(form).to be_invalid
      expect(form.errors[:work_email]).to be_present
    end

    it "validates the email format" do
      form = CarrierForm.new(work_email: "foobar")

      expect(form).to be_invalid
      expect(form.errors[:work_email]).to be_present
    end
  end

  describe "#save" do
    it "creates a carrier" do
      stub_rating_engine_request

      form = CarrierForm.new(
        name: "John Doe",
        work_email: "johndoe@example.com",
        company: "AT&T",
        subdomain: "at-t",
        country: "KH",
        website: "https://example.com",
        password: "Super Secret",
        password_confirmation: "Super Secret"
      )

      result = form.save

      expect(result).to eq(true)
      expect(form.user).to have_attributes(
        name: "John Doe",
        email: "johndoe@example.com",
        carrier_role: "owner"
      )
      expect(form.user.carrier).to have_attributes(
        name: "AT&T",
        country_code: "KH",
        restricted: true
      )
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end
  end
end
