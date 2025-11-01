class AccountForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :name
  attribute :enabled, :boolean, default: true
  attribute :object, default: -> { Account.new(type: :carrier_managed, access_token: Doorkeeper::AccessToken.new) }
  attribute :sip_trunk_id
  attribute :owner_name
  attribute :owner_email
  attribute :current_user
  attribute :calls_per_second, :integer, default: 1
  attribute :default_tts_voice, TTSVoiceType.new, default: -> { TTSVoices::Voice.default }
  attribute :tariff_bundle_id
  attribute :tariff_package_line_items,
            FormCollectionType.new(form: AccountTariffPackageForm),
            default: []

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
  validate :validate_tariff_package_line_items

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
      tariff_package_line_items: object.tariff_package_line_items
    )
  end

  def initialize(**)
    super(**)
    self.object.carrier = carrier
    self.tariff_bundle_id = carrier.default_tariff_bundle_id
    self.tariff_package_line_items = build_tariff_package_line_items
  end

  def tariff_package_line_items=(value)
    super
    tariff_package_line_items.each { _1.account = object }
  end

  def save
    return false if invalid?

    Account.transaction do
      object.carrier = carrier
      object.status = enabled ? "enabled" : "disabled"
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
      filled_tariff_package_line_items.all? { _1.save }
    end
  end

  def sip_trunk_options_for_select
    sip_trunks = carrier.sip_trunks.select(&:configured_for_outbound_dialing?)
    sip_trunks.map { |item| [ item.name, item.id ] }
  end

  def tariff_bundles_options_for_select
    carrier.tariff_bundles.includes(:tariff_packages).map do |tariff_bundle|
      [
        tariff_bundle.name,
        tariff_bundle.id,
        {
          data: {
            tariff_packages: tariff_bundle.tariff_packages.each_with_object({}) do |tariff_package, result|
              result[tariff_package.category] = tariff_package.id
            end
          }
        }
      ]
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

  def filled_tariff_package_line_items
    tariff_package_line_items.select(&:filled?)
  end

  def build_tariff_package_line_items
    default_tariff_bundle = carrier.default_tariff_bundle
    default_packages = Array(new_record? ? default_tariff_bundle&.tariff_packages : [])
    default_line_items = TariffSchedule.category.values.map do |category|
      AccountTariffPackageForm.new(
        category:,
        tariff_package_id: default_packages.find { _1.category == category }&.id
      )
    end
    collection = default_line_items.each_with_object([]) do |default_line_item, result|
      existing_line_item = tariff_package_line_items.find { _1.category == default_line_item.category }
      result << (existing_line_item || default_line_item)
    end

    FormCollection.new(collection, form: AccountTariffPackageForm)
  end

  def validate_tariff_package_line_items
    return if filled_tariff_package_line_items.none?(&:invalid?)

    errors.add(:tariff_package_line_items, :invalid)
  end
end
