class TariffPlanAssignmentForm < ApplicationForm
  attribute :id
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
      category: object.category,
      enabled: object.plan_id.present?
    )
  end

  def save
    return false if invalid?
    return object.destroy! if object.persisted? && !enabled?
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

  def plans
    @plans ||= carrier.tariff_plans.where(category:)
  end
end
