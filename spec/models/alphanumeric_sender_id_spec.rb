require "rails_helper"

RSpec.describe AlphanumericSenderID do
  describe "state machine" do
    it "handles state transitions" do
      carrier = create(:carrier)
      create(:alphanumeric_sender_id, :approved, account: create(:account, carrier:), sender_id: "VERIFY")

      expect(AlphanumericSenderID.new.status).to eq(:pending_approval)
      assert_transition_of(
        create(:alphanumeric_sender_id, :pending_approval),
        to: :approved,
        touch: :approved_at
      )
      assert_no_transition_of(create(:alphanumeric_sender_id, :pending_approval, sender_id: "VERIFY"), to: :approved)
      assert_no_transition_of(create(:alphanumeric_sender_id, :pending_approval), to: :revoked)
      assert_no_transition_of(create(:alphanumeric_sender_id, :approved), to: :rejected)
      assert_no_transition_of(create(:alphanumeric_sender_id, :revoked), to: :approved)
      assert_no_transition_of(create(:alphanumeric_sender_id, :rejected), to: :approved)
    end
  end

  def assert_transition_of(object, to:, **options)
    expect(object.transition_to(to, **options)).to be_truthy
    expect(object.status).to eq(to.to_s)
    expect(object.attributes.fetch(options.fetch(:touch).to_s)).to be_present if options.key?(:touch)
  end

  def assert_no_transition_of(object, to:, **)
    expect(object.transition_to(to, **)).to be_falsey
    expect(object.status).not_to eq(to.to_s)
  end
end
