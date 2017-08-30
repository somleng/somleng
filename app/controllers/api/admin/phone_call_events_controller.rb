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
    },
    "recording_started" => {
      "event_type" => PhoneCallEvent::RecordingStarted,
      "listeners" => [PhoneCallEvent::RecordingStartedObserver]
    },
    "recording_completed" => {
      "event_type" => PhoneCallEvent::RecordingCompleted,
      "listeners" => [PhoneCallEvent::RecordingCompletedObserver]
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

  def respond_with_create_resource
    if resource.errors.empty?
      head(:created, :location => api_admin_phone_call_phone_call_event_path(phone_call, resource))
    else
      super
    end
  end

  def subscribe_listeners
    (event_type_settings["listeners"] || []).each do |event_type_listener|
      resource.subscribe(event_type_listener.new)
    end
  end

  def permitted_params
    params.permit(:params => {})
  end
end
