require "rails_helper"

RSpec.describe SMSGatewayForm do
  describe "validations" do
    it "validates alphanumeric sender ids" do
      form = SMSGatewayForm.new(sender_id: "Foobar")

      form.valid?

      expect(form.errors[:sender_id]).to be_blank

      form = SMSGatewayForm.new(sender_id: "12345")

      form.valid?

      expect(form.errors[:sender_id]).to be_blank

      form = SMSGatewayForm.new(sender_id: "123423456789")

      form.valid?

      expect(form.errors[:sender_id]).to be_blank
    end
  end
end
