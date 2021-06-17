require "rails_helper"

RSpec.describe InboundSIPTrunkForm do
  describe "validations" do
    it "validates source IP" do
      form = InboundSIPTrunkForm.new(source_ip: "96.9.66.256")

      expect(form).to be_invalid
      expect(form.errors[:source_ip]).to be_present
    end
  end
end
