class TariffPlanAssignmentForm < ApplicationForm
  attribute :id
  attribute :object
  attribute :plan_id
  attribute :category

  validates :plan_id, presence: true, if: ->(form) { form.id.blank? }

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      plan_id: object.plan_id,
      category: object.category
    )
  end

  def save
    return false if invalid?

    self.object = object.class.where(**parent_attributes, category:).find(id) if id.present?

    return object.destroy! if destroy?

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

  def filled?
    id.present? || plan_id.present?
  end

  private

  def destroy?
    object.persisted? && plan_id.blank?
  end

  def plans
    @plans ||= carrier.tariff_plans.where(category:)
  end
end
