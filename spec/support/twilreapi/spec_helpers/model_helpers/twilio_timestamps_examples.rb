shared_examples_for "twilio_timestamps" do
  describe "timestamps" do
    let(:timestamp) { Time.new(2014, 03, 01, 0, 0, 0, "+00:00") }
    let(:asserted_rfc2822_time) { "Sat, 01 Mar 2014 00:00:00 +0000" }

    subject { create(factory, :created_at => timestamp, :updated_at => timestamp) }

    def assert_rfc2822!(result)
      expect(result).to eq(asserted_rfc2822_time)
    end

    describe "#date_created" do
      it { assert_rfc2822!(subject.date_created) }
    end

    describe "#date_updated" do
      it { assert_rfc2822!(subject.date_updated) }
    end
  end
end
