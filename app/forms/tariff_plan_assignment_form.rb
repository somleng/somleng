class TariffPlanAssignmentForm < ApplicationForm
  attribute :id
  attribute :object
  attribute :plan_id
  attribute :category
  attribute :enabled, :boolean, default: false

  validates :plan_id, presence: true, if: ->(form) { form.enabled? }

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      plan_id: object.plan_id,
      category: object.category
    )
  end

  def initialize(**)
    super(**)
    self.enabled = plan_id.present?
  end

  def save
    return false if invalid?

    self.object = object.class.where(**parent_attributes, category:).find(id) if id.present?

    return object.destroy! if destroy?
    return true unless enabled?

    object.attributes = {
      **parent_attributes,
      plan: plans.find(plan_id),
      category:
    }

    object.save!
  end

  def plans_options_for_select
    DecoratedCollection.new(plans).map do |item|
      [ item.name, item.id ]
    end
  end

  def enabled?
    !!enabled
  end

  private

  def destroy?
    object.persisted? && !enabled?
  end

  def plans
    @plans ||= carrier.tariff_plans.where(category:)
  end
end
