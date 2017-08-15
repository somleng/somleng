class Api::Admin::PhoneCallEventsController < Api::Admin::BaseController
  EVENT_TYPES = {
    "ringing" => {
      "event_type" => PhoneCallEvent::Ringing,
      "listeners" => [PhoneCallEvent::RingingObserver]
    },
    "answered" => {
      "event_type" => PhoneCallEvent::Answered,
      "listeners" => [PhoneCallEvent::AnsweredObserver]
    },
    "completed" => {
      "event_type" => PhoneCallEvent::Completed,
      "listeners" => [PhoneCallEvent::CompletedObserver]
    }
  }

  private

  def permission_name
    :manage_phone_call_events
  end

  def association_chain
    event_type_settings["event_type"] || PhoneCallEvent::Base
  end

  def event_type_settings
    EVENT_TYPES[params["type"]] || {}
  end

  def setup_resource
    subscribe_listeners
    resource.phone_call = phone_call
    resource
  end

  def phone_call
    @phone_call ||= by_uuid(:id).or(by_uuid(:external_id)).first!
  end

  def by_uuid(field)
    PhoneCall.where(field => params[:phone_call_id])
  end

  def respond_with_options
    super.merge(
      :location => Proc.new { api_admin_phone_call_phone_call_events_path(phone_call, resource) }
    )
  end

  def subscribe_listeners
    (event_type_settings["listeners"] || []).each do |event_type_listener|
      resource.subscribe(event_type_listener.new)
    end
  end

  def permitted_params
    params.permit(
      :sip_term_status,
      :answer_epoch
    )
  end
end
