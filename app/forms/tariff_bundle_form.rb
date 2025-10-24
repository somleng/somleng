class TariffBundleForm < ApplicationForm
  attribute :carrier
  attribute :object, default: -> { TariffBundle.new }
  attribute :name
  attribute :description
  attribute :line_items,
            FormCollectionType.new(form: TariffBundleLineItemForm),
            default: []

  validates :name, presence: true
  validate :validate_line_items

  delegate :persisted?, :new_record?, :id, to: :object

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundle")
  end

  def initialize(**)
    super(**)
    self.object.carrier = carrier
    self.line_items = build_line_items
  end

  def line_items=(value)
    super
    line_items.each { _1.tariff_bundle = object }
  end

  def self.initialize_with(tariff_bundle)
    new(
      object: tariff_bundle,
      carrier: tariff_bundle.carrier,
      name: tariff_bundle.name,
      description: tariff_bundle.description,
      line_items: tariff_bundle.line_items
    )
  end

  def save
    return false if invalid?

    object.attributes = {
      carrier:,
      name:,
      description: description.presence
    }

    filled_line_items.each { _1.tariff_bundle ||= object }

    ApplicationRecord.transaction do
      object.save!
      filled_line_items.all? { _1.save }
    end
  end

  def line_items_by_category_type
    line_items.each_with_object(Hash.new { |h, k| h[k] = [] }) do |line_item, result|
      result[line_item.category.type] << line_item
    end
  end

  private

  def filled_line_items
    line_items.select(&:filled?)
  end

  def build_line_items
    default_line_items = TariffSchedule.category.values.map { |category| TariffBundleLineItemForm.new(category:) }
    collection = default_line_items.each_with_object([]) do |default_line_item, result|
      existing_line_item = line_items.find { _1.category == default_line_item.category }
      result << (existing_line_item || default_line_item)
    end

    FormCollection.new(collection, form: TariffBundleLineItemForm)
  end

  def validate_line_items
    return if filled_line_items.none?(&:invalid?)

    errors.add(:line_items, :invalid)
  end
end
