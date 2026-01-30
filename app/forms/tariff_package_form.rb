class TariffPackageForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { TariffPackage.new }
  attribute :name
  attribute :description
  attribute :plans,
            FormCollectionType.new(form: TariffPackagePlanForm),
            default: []

  validates :name, presence: true
  validate :validate_name
  validate :validate_plans

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPackage")
  end

  def initialize(**)
    super(**)
    self.object.carrier = carrier
    self.plans = build_plans
  end

  def plans=(value)
    super
    plans.each { _1.package = object }
  end

  def self.initialize_with(tariff_package)
    new(
      object: tariff_package,
      carrier: tariff_package.carrier,
      name: tariff_package.name,
      description: tariff_package.description,
      plans: tariff_package.package_plans
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      name:,
      description: description.presence
    }

    ApplicationRecord.transaction do
      object.save!
      plans.all? { _1.save }
    end
  end

  private

  def build_plans
    default_plans = TariffSchedule.category.values.map { |category| TariffPackagePlanForm.new(category:) }
    collection = default_plans.each_with_object([]) do |default_plan, result|
      existing_plan = plans.find { _1.category == default_plan.category }
      result << (existing_plan || default_plan)
    end

    FormCollection.new(collection, form: TariffPackagePlanForm)
  end

  def validate_name
    return unless carrier.tariff_packages.where.not(id: object.id).exists?(name:)

    errors.add(:name, :taken)
  end

  def validate_plans
    if plans.select(&:enabled).blank?
      plans.first.errors.add(:plan_id, :blank)
      return errors.add(:plans, :invalid)
    end

    plans.each(&:valid?)
    errors.add(:plans, :invalid) if plans.any? { _1.errors.present? }
  end
end
