class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze

  def seed!
    carrier, carrier_owner = create_carrier
    sip_trunk = create_sip_trunk(carrier:)
    carrier_managed_account = create_carrier_managed_account(carrier:)
    create_customer_managed_account(carrier:)
    create_error_log_notification(
      carrier:,
      user: carrier_owner,
      type: :inbound_message,
      error_message: "Phone number 523346380009 does not exist."
    )
    phone_number = create_phone_number(carrier:)
    plan = create_phone_number_plan(phone_number:, account: carrier_managed_account)
    create_phone_call(
      carrier:,
      account: carrier_managed_account,
      sip_trunk:,
      phone_number:,
      incoming_phone_number: plan.incoming_phone_number
    )
    sms_gateway = create_sms_gateway(carrier:)

    puts(<<~INFO)
      Account SID:              #{carrier_managed_account.id}
      Auth Token:               #{carrier_managed_account.auth_token}
      Phone Number:             #{phone_number.number}
      SMS Gateway Device Token: #{sms_gateway.device_token}
      ---------------------------------------------
      URL:                      #{url_helpers.dashboard_root_url(host: carrier.subdomain_host)}
      Carrier User Email:       #{carrier_owner.email}
      Carrier User Password:    #{USER_PASSWORD}
      Carrier API Key:          #{carrier.api_key}
    INFO
  end

  private

  def create_sip_trunk(params)
    SIPTrunk.first_or_create!(
      params.reverse_merge(
        name: "My SIP Trunk",
        region: "hydrogen",
        outbound_host: "host.docker.internal:5061",
        inbound_source_ips: ENV.fetch("HOST_IP", "127.0.0.1"),
        authentication_mode: :ip_address
      )
    )
  end

  def create_sms_gateway(**params)
    SMSGateway.first_or_create!(name: "My SMS Gateway", **params)
  end

  def create_carrier_managed_account(**params)
    return Account.carrier_managed.first if Account.carrier_managed.exists?

    carrier = params.fetch(:carrier)

    create_account(
      name: carrier.name,
      type: :carrier_managed,
      **params
    )
  end

  def create_customer_managed_account(**params)
    if Account.customer_managed.exists?
      account = Account.customer_managed.first!
      customer = account.users.first!

      return [ account, customer ]
    end

    carrier = params.fetch(:carrier)
    account = create_account(name: "Customer Account", type: :customer_managed, **params)

    customer = User.create!(
      build_user_params(
        carrier:,
        email: "customer@example.com",
        name: "Bob Chan"
      )
    )
    AccountMembership.create!(account:, user: customer, role: :owner)

    [ account, customer ]
  end

  def create_phone_number(params)
    PhoneNumber.first_or_create!(
      number: "1294",
      iso_country_code: "KH",
      type: :short_code,
      visibility: :public,
      **params
    )
  end

  def create_phone_number_plan(phone_number:, **params)
    return phone_number.active_plan if phone_number.assigned?

    CreatePhoneNumberPlan.call(phone_number:, **params)
  end

  def create_incoming_phone_number(params)
    IncomingPhoneNumber.first_or_create!(
      voice_url: "https://demo.twilio.com/docs/voice.xml",
      voice_method: "GET",
      **params
    )
  end

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end

  def create_account(**params, &block)
    Account.create!(
      default_tts_voice: TTSVoices::Voice.default,
      **params,
      &:build_access_token
    )
  end

  def build_user_params(**params)
    {
      password: USER_PASSWORD,
      confirmed_at: Time.current,
      **params
    }
  end

  def create_error_log_notification(**params)
    account = params.delete(:account)
    carrier = params.delete(:carrier) || account&.carrier
    type = params.delete(:type)
    user = params.fetch(:user)
    error_message = params.delete(:error_message) || "An error occurred"

    return if ErrorLogNotification.exists?(user:, message_digest: error_message)

    error_log = ErrorLog.create!(carrier:, account:, error_message:, type:)

    ErrorLogNotification.create!(
      error_log:,
      user:,
      email: user.email,
      message_digest: error_log.error_message,
      **params
    )
  end

  def create_phone_call(**params)
    return if PhoneCall.exists?

    phone_number = params.fetch(:phone_number)

    PhoneCall.create!(
      direction: :outbound_api,
      from: phone_number.number,
      to: "855715100678",
      **params
    )
  end

  def create_carrier
    if Carrier.exists?
      carrier = Carrier.first
      carrier_member = carrier.carrier_users.first

      return [ carrier, carrier_member ]
    end

    OnboardCarrier.call(
      name: "My Carrier",
      country_code: "KH",
      restricted: false,
      subdomain: "my-carrier",
      website: "https://example.com",
      billing_currency: "USD",
      owner: build_user_params(
        email: "johndoe@carrier.com",
        name: "John Doe",
        carrier_role: :owner
      )
    )
  end
end
