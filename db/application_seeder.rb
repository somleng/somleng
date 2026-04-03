class ApplicationSeeder
  USER_PASSWORD = "Somleng1234!".freeze
  BILLING_CURRENCY = "USD"
  RATES = {
    outbound_calls: InfinitePrecisionMoney.from_amount(0.10, BILLING_CURRENCY),
    inbound_calls: InfinitePrecisionMoney.from_amount(0.02, BILLING_CURRENCY),
    outbound_messages: InfinitePrecisionMoney.from_amount(0.05, BILLING_CURRENCY),
    inbound_messages: InfinitePrecisionMoney.from_amount(0.01, BILLING_CURRENCY)
  }.freeze
  TOPUP_AMOUNT = Money.from_amount(100, BILLING_CURRENCY)

  Form = Data.define(:object) do
    delegate :save, to: :object
  end

  attr_reader :rating_engine_client

  def initialize(**options)
    @rating_engine_client = options.fetch(:rating_engine_client) { RatingEngineClient.new }
  end

  def seed!
    carrier, carrier_owner = create_carrier
    sip_trunk = create_sip_trunk(carrier:)
    carrier_managed_account = create_carrier_managed_account(carrier:, billing_enabled: true)
    setup_billing_for(carrier_managed_account)
    create_topup_for(carrier_managed_account)
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

  def create_account(**)
    Account.create!(default_tts_voice: TTSVoices::Voice.default, **, &:build_access_token)
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
      region: "hydrogen",
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
      billing_currency: BILLING_CURRENCY,
      owner: build_user_params(
        email: "johndoe@carrier.com",
        name: "John Doe",
        carrier_role: :owner
      ),
      rating_engine_client:
    )
  end

  def setup_billing_for(account)
    return if account.tariff_plan_subscriptions.exists?

    tariff_package = create_tariff_package_for(account.carrier)
    account.carrier.update!(default_tariff_package: tariff_package)
    tariff_package.plans.each do |plan|
      account.tariff_plan_subscriptions.create!(
        plan: plan,
        category: plan.category
      )
    end

    UpdateAccountForm.call(Form.new(object: account), client: rating_engine_client)
  end

  def create_tariff_package_for(carrier)
    return carrier.tariff_packages.first if carrier.tariff_packages.exists?

    package = TariffPackage.create!(carrier:, name: "Standard")
    TariffSchedule.category.values.each do |category|
      CreateTariffPackagePlanWithDefaults.call(package:, category:, rate: RATES.fetch(category.to_sym))
    end

    CreateTariffPackageWizardForm.call(Form.new(object: package), client: rating_engine_client)
  end

  def create_topup_for(account)
    return if account.balance_transactions.exists?

    balance_transaction = BalanceTransaction.create!(
      account:,
      carrier: account.carrier,
      type: "topup",
      amount_cents: TOPUP_AMOUNT.cents,
      currency: TOPUP_AMOUNT.currency,
      description: "Initial balance"
    )

    UpdateAccountBalanceForm.call(Form.new(object: balance_transaction), client: rating_engine_client)
  end
end
