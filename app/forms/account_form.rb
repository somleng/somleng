class AccountForm < ApplicationForm
  attribute :carrier
  attribute :name
  attribute :enabled, :boolean, default: true
  attribute :billing_enabled, :boolean, default: false
  attribute :billing_mode
  attribute :object, default: -> { Account.new(type: :carrier_managed, access_token: Doorkeeper::AccessToken.new) }
  attribute :sip_trunk_id
  attribute :owner_name
  attribute :owner_email
  attribute :current_user
  attribute :calls_per_second, :integer, default: 1
  attribute :default_tts_voice, TTSVoiceType.new, default: -> { TTSVoices::Voice.default }
  attribute :tariff_package_id
  attribute :tariff_plan_subscriptions,
            FormCollectionType.new(form: TariffPlanSubscriptionForm),
            default: []

  enumerize :billing_mode, in: Account.billing_mode.values, default: :prepaid

  delegate :new_record?, :persisted?, :id, :customer_managed?, :carrier_managed?, to: :object

  validates :default_tts_voice, presence: true
  validates :name, presence: true, unless: :customer_managed?
  validates :owner_email, email_format: true, allow_blank: true, allow_nil: true
  validates :calls_per_second,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 100,
              only_integer: true
            }

  validate :validate_owner

  def self.model_name
    ActiveModel::Name.new(self, nil, "Account")
  end

  def self.initialize_with(object)
    new(
      object:,
      carrier: object.carrier,
      name: object.name,
      sip_trunk_id: object.sip_trunk_id,
      enabled: object.enabled?,
      calls_per_second: object.calls_per_second,
      owner_name: object.owner&.name,
      owner_email: object.owner&.email,
      default_tts_voice: object.default_tts_voice,
      billing_enabled: object.billing_enabled?,
      billing_mode: object.billing_mode,
      tariff_plan_subscriptions: object.tariff_plan_subscriptions
    )
  end

  def initialize(**)
    super(**)
    self.object.carrier = carrier
    self.tariff_package_id = carrier.default_tariff_package_id
    self.tariff_plan_subscriptions = build_tariff_plan_subscriptions
  end

  def tariff_plan_subscriptions=(value)
    super
    tariff_plan_subscriptions.each { _1.account = object }
  end

  def save
    return false if invalid?

    Account.transaction do
      object.carrier = carrier
      object.status = enabled ? "enabled" : "disabled"
      object.billing_enabled = billing_enabled
      object.billing_mode = billing_mode
      object.calls_per_second = calls_per_second
      object.sip_trunk = sip_trunk_id.present? ? carrier.sip_trunks.find(sip_trunk_id) : nil
      if carrier_managed?
        object.name = name
        object.default_tts_voice = default_tts_voice

        if owner_email.present?
          object.type = :customer_managed
          invite_owner!
        end
      end

      object.save!
      filled_tariff_plan_subscriptions.all? { _1.save }
    end
  end

  def sip_trunk_options_for_select
    sip_trunks = carrier.sip_trunks.select(&:configured_for_outbound_dialing?)
    sip_trunks.map { |item| [ item.name, item.id ] }
  end

  def tariff_packages_options_for_select
    DecoratedCollection.new(carrier.tariff_packages).map { [ _1.name, _1.id ] }
  end

  def tariff_plans_by_category
    carrier.tariff_packages.includes(:package_plans).each_with_object({}) do |package, result|
      result[package.id] = package.package_plans.each_with_object({}) do |package_plan, category_result|
        category_result[package_plan.category] = package_plan.plan_id
      end
    end
  end

  private

  def validate_owner
    return if owner_email.blank? && owner_name.blank?
    return errors.add(:owner_email, :blank) if owner_name.present? && owner_email.blank?
    return errors.add(:owner_name, :blank) if owner_email.present? && owner_name.blank?

    errors.add(:owner_email, :taken) if User.carrier.exists?(email: owner_email)
  end

  def invite_owner!
    AccountMembership.create!(
      account: object,
      user: User.invite!({ carrier:, email: owner_email, name: owner_name }, current_user),
      role: :owner
    )
  end

  def filled_tariff_plan_subscriptions
    tariff_plan_subscriptions.select(&:filled?)
  end

  def build_tariff_plan_subscriptions
    default_tariff_package = carrier.default_tariff_package
    default_plans = Array(new_record? ? default_tariff_package&.plans : [])
    default_subscriptions = TariffSchedule.category.values.map do |category|
      TariffPlanSubscriptionForm.new(
        category:,
        plan_id: default_plans.find { _1.category == category }&.id
      )
    end
    collection = default_subscriptions.each_with_object([]) do |default_plan, result|
      existing_plan = tariff_plan_subscriptions.find { _1.category == default_plan.category }
      result << (existing_plan || default_plan)
    end

    FormCollection.new(collection, form: TariffPlanSubscriptionForm)
  end
end
