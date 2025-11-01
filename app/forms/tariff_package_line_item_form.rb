class TariffPackageLineItemForm < ApplicationForm
  attribute :id
  attribute :object
  attribute :tariff_package_id
  attribute :category

  validates :tariff_package_id, presence: true, if: ->(form) { form.id.blank? }

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      tariff_package_id: object.tariff_package_id,
      category: object.category
    )
  end

  def save
    return false if invalid?

    self.object = object.class.where(**parent_attributes, category:).find(id) if id.present?

    return object.destroy! if destroy?

    object.attributes = {
      **parent_attributes,
      tariff_package: tariff_packages.find(tariff_package_id),
      category:
    }

    object.save!
  end

  def tariff_packages_options_for_select
    decorated_collection(tariff_packages) do |item|
      [ item.name, item.id ]
    end
  end

  def filled?
    id.present? || tariff_package_id.present?
  end

  private

  def destroy?
    object.persisted? && tariff_package_id.blank?
  end

  def tariff_packages
    @tariff_packages ||= carrier.tariff_packages.where(category:)
  end

  def decorated_collection(collection)
    collection.map do |item|
      decorated_item = item.decorated
      yield(decorated_item)
    end
  end
end
