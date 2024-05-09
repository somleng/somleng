class UpdatePhoneCall < ApplicationWorkflow
  attr_reader :phone_call, :params

  def initialize(phone_call, **params)
    @phone_call = phone_call
    @params = params
  end

  def call
    return unless phone_call.uncompleted?

    params[:status].present? ? end_call : update_call
  end

  private

  def end_call
    if phone_call.was_initiated?
      phone_call.touch(:user_terminated_at)
      UpdateLiveCallJob.perform_later(phone_call)
    else
      phone_call.transaction do
        phone_call.touch(:user_terminated_at)
        phone_call.cancel!
      end
    end
  end

  def update_call
    phone_call.update!(user_updated_at: Time.current, **params)
    UpdateLiveCallJob.perform_later(phone_call) if update_live_call? && phone_call.was_initiated?
  end

  def update_live_call?
    params[:voice_url].present? || params[:twiml].present?
  end
end
