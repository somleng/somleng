class InitiateOutboundCall < ApplicationWorkflow
  class Error < StandardError; end

  attr_reader :phone_call, :call_service_client, :session_limiters, :logger

  def initialize(**options)
    super()
    @phone_call = options.fetch(:phone_call) { PhoneCall.find(options.fetch(:phone_call_id)) }
    @call_service_client = options.fetch(:call_service_client) { CallService::Client.new }
    @session_limiters = options.fetch(:session_limiters) { [ AccountCallSessionLimiter.new(logger:), GlobalCallSessionLimiter.new(logger:) ] }
    @logger = options.fetch(:logger) { Rails.logger }
  end

  def call
    return unless phone_call.status.in?(%w[queued initiating])
    return phone_call.cancel! if phone_call.sip_trunk.blank?
    return reschedule unless initiate!

    response = create_remote_call

    mark_as_initiated!(
      response.fetch(:id),
      call_service_host: response.fetch(:host)
    )
  end

  private

  def reschedule
    ExecuteWorkflowJob.set(
      queue: AppSettings.fetch(:aws_sqs_high_priority_queue_name),
      wait_until: 10.seconds.from_now
    ).perform_later(
      InitiateOutboundCall.to_s,
      phone_call:
    )
  end

  def session_limits_exceeded?
    session_limiters.any? do |limiter|
      if limiter.exceeds_limit?(phone_call.region.alias, scope: phone_call.account_id)
        logger.warn("Session limit exceeded for limiter: #{limiter.class} (Account ID: #{phone_call.account_id})")
        true
      end
    end
  end

  def initiate!
    return false if session_limits_exceeded?
    return mark_as_initiating! if phone_call.sip_trunk.max_channels.blank?

    SIPTrunkChannelManager.allocate_sip_trunk_channel(sip_trunk) do
      mark_as_initiating! if channels_available?
    end
  end

  def create_remote_call
    response = call_service_client.create_call(
      region: phone_call.region.alias,
      sid: decorated_phone_call.sid,
      carrier_sid: decorated_phone_call.carrier_sid,
      account_sid: decorated_phone_call.account_sid,
      account_auth_token: decorated_phone_call.account.auth_token,
      direction: decorated_phone_call.direction,
      api_version: TwilioAPI::ResourceSerializer::API_VERSION,
      voice_url: decorated_phone_call.voice_url,
      voice_method: decorated_phone_call.voice_method,
      twiml: decorated_phone_call.twiml,
      to: decorated_phone_call.to,
      from: decorated_phone_call.caller_id,
      default_tts_voice: decorated_phone_call.default_tts_voice.identifier,
      routing_parameters: RoutingParameters.new(
        sip_trunk: phone_call.sip_trunk,
        destination: phone_call.to
      ).to_h,
      billing_parameters: {
        enabled: phone_call.account.billing_enabled?,
        category: phone_call.tariff_schedule_category.to_s,
        billing_mode: phone_call.account.billing_mode
      }
    )

    raise Error, "Response body: #{response.body}" unless response.success?
    increment_session_limits

    response
  end

  def increment_session_limits
    session_limiters.each { _1.add_session_to(phone_call.region.alias, scope: phone_call.account_id) }
  end

  def channels_available?
    sip_trunk.max_channels > in_progress_calls.count
  end

  def sip_trunk
    phone_call.sip_trunk
  end

  def mark_as_initiating!
    phone_call.initiating_at = Time.current
    phone_call.mark_as_initiating!
  end

  def mark_as_initiated!(external_id, **attributes)
    phone_call.external_id = external_id
    phone_call.initiated_at = Time.current
    phone_call.attributes = attributes
    phone_call.mark_as_initiated!
  end

  def decorated_phone_call
    @decorated_phone_call ||= PhoneCallDecorator.new(phone_call)
  end

  def in_progress_calls
    sip_trunk.phone_calls.in_progress_or_initiating.where(created_at: 1.hour.ago..)
  end
end
