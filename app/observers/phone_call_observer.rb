class PhoneCallObserver < ApplicationObserver
  def phone_call_completed(phone_call)
    if phone_call.status_callback_url?
      JobAdapter.new(:status_callback_notifier_worker).perform_later(phone_call.id)
    end
  end
end
