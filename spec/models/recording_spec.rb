require 'rails_helper'

RSpec.describe Recording do
  let(:factory) { :recording }

  describe "associations" do
    it { is_expected.to belong_to(:phone_call) }
    it { is_expected.to have_one(:currently_recording_phone_call) }
    it { is_expected.to have_many(:phone_call_events) }
    it { is_expected.to have_many(:aws_sns_notifications) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }

    context "persisted" do
      subject { create(factory) }
      it { is_expected.to validate_uniqueness_of(:original_file_id).case_insensitive }
    end
  end
end
