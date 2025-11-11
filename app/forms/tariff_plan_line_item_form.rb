class TariffPlanLineItemForm < ApplicationForm
  attribute :id
  attribute :object
  attribute :tariff_plan_id
  attribute :category

  validates :tariff_plan_id, presence: true, if: ->(form) { form.id.blank? }

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      tariff_plan_id: object.tariff_plan_id,
      category: object.category
    )
  end

  def save
    return false if invalid?

    self.object = object.class.where(**parent_attributes, category:).find(id) if id.present?

    return object.destroy! if destroy?

    object.attributes = {
      **parent_attributes,
      tariff_plan: tariff_plans.find(tariff_plan_id),
      category:
    }

    object.save!
  end

  def tariff_plans_options_for_select
    decorated_collection(tariff_plans) do |item|
      [ item.name, item.id ]
    end
  end

  def filled?
    id.present? || tariff_plan_id.present?
  end

  private

  def destroy?
    object.persisted? && tariff_plan_id.blank?
  end

  def tariff_plans
    @tariff_plans ||= carrier.tariff_plans.where(category:)
  end

  def decorated_collection(collection)
    collection.map do |item|
      decorated_item = item.decorated
      yield(decorated_item)
    end
  end
end
