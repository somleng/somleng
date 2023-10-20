require "rails_helper"

RSpec.describe AccountSettingsForm do
  describe "validations" do
    it "validates name" do
      form = AccountSettingsForm.new(
        name: nil
      )

      expect(form).to be_invalid
      expect(form.errors[:name]).to be_present
    end

    it "validates default_tts_voice" do
      form = AccountSettingsForm.new(
        default_tts_voice: "Voice.Invalid"
      )

      expect(form).to be_invalid
      expect(form.errors[:default_tts_voice]).to be_present
    end
  end

  describe "#save" do
    it "saves the account settings" do
      account = create(:account)

      form = AccountSettingsForm.new(
        account:,
        name: "Rocket Rides",
        default_tts_voice: "Basic.Slt"
      )

      result = form.save

      expect(result).to eq(true)
      expect(form.account).to have_attributes(
        name: "Rocket Rides",
        default_tts_voice: have_attributes(
          identifier: "Basic.Slt"
        )
      )
    end
  end
end
