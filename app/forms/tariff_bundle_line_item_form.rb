class TariffBundleLineItemForm < ApplicationForm
  attribute :id
  attribute :tariff_bundle
  attribute :tariff_package_id
  attribute :object, default: -> { TariffBundleLineItem.new }
  attribute :category

  validates :tariff_package_id, presence: true, if: ->(form) { form.id.blank? }

  delegate :carrier, to: :tariff_bundle

  enumerize :category, in: TariffSchedule.category.values, value_class: TariffScheduleCategoryValue

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundleLineItem")
  end

  def self.initialize_with(object)
    new(
      object:,
      id: object.id,
      tariff_bundle: object.tariff_bundle,
      tariff_package_id: object.tariff_package_id,
      category: object.category
    )
  end

  def save
    return false if invalid?

    self.object = tariff_bundle.line_items.where(category:).find(id) if id.present?

    return object.destroy! if object.persisted? && tariff_package_id.blank?

    object.attributes = {
      tariff_bundle:,
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
