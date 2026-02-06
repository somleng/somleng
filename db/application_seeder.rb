class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze
  OUTBOUND_CALLS_RATE = 0.10
  INBOUND_CALLS_RATE = 0.02
  OUTBOUND_MESSAGES_RATE = 0.05
  INBOUND_MESSAGES_RATE = 0.01

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

    tariff_package = create_tariff_package(carrier:)
    assign_tariff_package(account: carrier_managed_account, tariff_package:)

    create_topup(carrier_managed_account)

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
      ---------------------------------------------
      Outbound Calls Rate:      #{OUTBOUND_CALLS_RATE}
      Inbound Calls Rate:       #{INBOUND_CALLS_RATE}
      Outbound Messages Rate:   #{OUTBOUND_MESSAGES_RATE}
      Inbound Messages Rate:    #{INBOUND_MESSAGES_RATE}
      ---------------------------------------------
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

  def create_tariff_package(carrier:)
    return TariffPackage.first if TariffPackage.exists?

    resource = TariffPackageWizardForm.new(
      carrier:,
      name: "My Tariff Package",
      tariffs: [
        { enabled: true, rate: OUTBOUND_CALLS_RATE, category: "outbound_calls" },
        { enabled: true, rate: INBOUND_CALLS_RATE, category: "inbound_calls" },
        { enabled: true, rate: OUTBOUND_MESSAGES_RATE, category: "outbound_messages" },
        { enabled: true, rate: INBOUND_MESSAGES_RATE, category: "inbound_messages" }
      ]
    )
    CreateTariffPackageWizardForm.call(resource)
  end

  def assign_tariff_package(account:, tariff_package:)
    tariff_package.plans.each do |plan|
      TariffPlanSubscription.find_or_create_by!(
        account:,
        plan:,
        category: plan.category
      )
    end
  end

  def create_topup(account)
    return if account.balance_transactions.exists?

    form = BalanceTransactionForm.new(
      carrier: account.carrier,
      account_id: account.id,
      type: "topup",
      amount: "100",
      description: "Initial balance"
    )
    UpdateAccountBalanceForm.call(form)
  end
end
