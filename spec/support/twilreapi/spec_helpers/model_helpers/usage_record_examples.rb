shared_examples_for "usage_record" do
  describe "#account_sid" do
    subject { build(factory) }
    it { expect(subject.account_sid).to be_present }
  end
end
