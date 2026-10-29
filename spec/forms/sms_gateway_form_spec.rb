require "rails_helper"

RSpec.describe SMSGatewayForm do
  describe "validations" do
    it "validates the sender id" do
      form = SMSGatewayForm.new(sender_id_behavior: :passthrough, sender_id: "Foobar")
      form.valid?
      expect(form.errors[:sender_id]).to be_present

      form = SMSGatewayForm.new(sender_id_behavior: :fallback, sender_id: nil)
      form.valid?
      expect(form.errors[:sender_id]).to be_present

      form = SMSGatewayForm.new(sender_id_behavior: :fallback, sender_id: "A" * 12)
      form.valid?
      expect(form.errors[:sender_id]).to be_present

      form = SMSGatewayForm.new(sender_id_behavior: :fallback, sender_id: "Foobar")
      form.valid?
      expect(form.errors[:sender_id]).to be_blank

      form = SMSGatewayForm.new(sender_id_behavior: :fallback, sender_id: "123423456789")
      form.valid?
      expect(form.errors[:sender_id]).to be_blank
    end
  end
end
