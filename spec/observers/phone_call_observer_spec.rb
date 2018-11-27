require "rails_helper"

RSpec.describe PhoneCallObserver do
  describe "#phone_call_completed" do
    it "does nothing if there is no status_callack_url" do
      phone_call = create(:phone_call, status_callback_url: nil)
      observer = described_class.new

      expect { observer.phone_call_completed(phone_call) }.not_to have_enqueued_job
    end

    it "enqueues job to notify the status_callack_url" do
      phone_call = create(
        :phone_call, status_callback_url: "https://scfm.somleng.org/api/remote_phone_call_events"
      )
      observer = described_class.new

      expect {
        observer.phone_call_completed(phone_call)
      }.to have_enqueued_job(ExecuteWorkflowJob).with("NotifyStatusCallbackUrl", phone_call)
    end
  end
end
