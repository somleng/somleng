class TariffPlanForm < ApplicationForm
  attribute :carrier
  attribute :category
  attribute :object, default: -> { TariffPlan.new }
  attribute :name
  attribute :description
  attribute :tiers

  attribute :tiers,
            FormCollectionType.new(form: TariffPlanTierForm),
            default: []

  enumerize :category, in: TariffPlan.category.values

  validates :name, :category, presence: true
  validate :validate_name
  validate :validate_tiers

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPlan")
  end

  def self.initialize_with(tariff_plan)
    new(
      object: tariff_plan,
      carrier: tariff_plan.carrier,
      name: tariff_plan.name,
      description: tariff_plan.description,
      category: tariff_plan.category,
      tiers: tariff_plan.tiers.order(weight: :desc)
    )
  end

  def initialize(**)
    super(**)
    object.carrier = carrier
    self.tiers = build_tiers if tiers.blank?
  end

  def tiers=(value)
    super(value)
    tiers.each { _1.attributes = { tariff_plan: object } }
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      category:,
      name:,
      description: description.presence
    }

    object.save!

    tiers.all?(&:save)
  end

  def retained_tiers
    tiers.select(&:retain?)
  end

  private

  def build_tiers
    FormCollection.new([ TariffPlanTierForm.new ], form: TariffPlanTierForm)
  end

  def validate_tiers
    retained_tiers.each(&:valid?)

    validate_uniqueness_of(:tariff_schedule_id, within: retained_tiers.group_by(&:tariff_schedule_id))
    validate_uniqueness_of(:weight, within: retained_tiers.group_by(&:weight))

    return if retained_tiers.all? { _1.errors.empty? }

    errors.add(:tiers, :invalid)
  end

  def validate_name
    return unless carrier.tariff_plans.where.not(id: object.id).exists?(name:, category:)

    errors.add(:name, :taken)
  end

  def validate_uniqueness_of(attribute, within:)
    within.each_value do |forms|
      next if forms.size <= 1

      forms.drop(1).each do |duplicate|
        duplicate.errors.add(attribute, :taken)
      end
    end
  end
end
