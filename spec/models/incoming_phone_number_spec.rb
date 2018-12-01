require "rails_helper"

RSpec.describe IncomingPhoneNumber do
  describe "validations" do
    it { expect(create(:incoming_phone_number)).to validate_uniqueness_of(:phone_number).strict.case_insensitive }
  end
end
