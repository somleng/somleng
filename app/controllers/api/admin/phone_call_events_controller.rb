class Api::Admin::PhoneCallEventsController < Api::Admin::BaseController
  EVENT_TYPES = {
    "ringing" => PhoneCallEvent::Ringing,
    "answered" => PhoneCallEvent::Answered,
    "completed" => PhoneCallEvent::Completed
  }

  private

  def permission_name
    :manage_phone_call_events
  end

  def association_chain
    EVENT_TYPES[params["type"]] || PhoneCallEvent::Base
  end

  def setup_resource
    resource.phone_call = phone_call
    resource
  end

  def phone_call
    PhoneCall.find(params[:phone_call_id])
  end

  def respond_with_options
    super.merge(
      :location => Proc.new { api_admin_phone_call_phone_call_events_path(phone_call, resource) }
    )
  end

  def permitted_params
    params.permit(
      :sip_term_status,
      :answer_epoch
    )
  end
end
