shared_examples_for "aws_sns_message" do
  describe "associations" do
    it { is_expected.to belong_to(:recording) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:aws_sns_message_id) }

    context "persisted" do
      subject { create(factory) }
      it { is_expected.to validate_uniqueness_of(:aws_sns_message_id).case_insensitive }
    end
  end

  describe "factory" do
    subject { create(factory) }
    it { is_expected.to be_valid }
  end

  include_examples("event_publisher")
end
