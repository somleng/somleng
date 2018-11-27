class PhoneCallObserver < ApplicationObserver
  def phone_call_completed(phone_call)
    return if phone_call.status_callback_url.blank?

    ExecuteWorkflowJob.perform_later(NotifyStatusCallbackUrl.to_s, phone_call)
  end
end
