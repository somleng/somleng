require 'rails_helper'

describe PhoneCallObserver do
  def phone_call_traits
    {}
  end

  def phone_call_attributes
    {}
  end

  let(:phone_call) {
    create(:phone_call, *phone_call_traits.keys, phone_call_attributes)
  }

  describe "#phone_call_completed(phone_call)" do
    let(:enqueued_job) { enqueued_jobs.first }

    def setup_scenario
      subject.phone_call_completed(phone_call)
    end

    before do
      setup_scenario
    end

    context "phone_call#status_callback_url? => true" do
      def phone_call_traits
        super.merge(:with_status_callback_url => true)
      end

      def assert_observed!
        expect(enqueued_job[:job]).to eq(StatusCallbackNotifierJob)
        expect(enqueued_job[:args]).to match_array([phone_call.id])
      end

      it { assert_observed! }
    end

    context "phone_call#status_callback_url? => false" do
      def assert_observed!
        expect(enqueued_job).to eq(nil)
      end

      it { assert_observed! }
    end
  end
end
