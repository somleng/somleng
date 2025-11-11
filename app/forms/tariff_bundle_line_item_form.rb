class TariffBundleLineItemForm < TariffPlanLineItemForm
  attribute :tariff_bundle
  attribute :object, default: -> { TariffBundleLineItem.new }

  delegate :carrier, to: :tariff_bundle

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundleLineItem")
  end

  def self.initialize_with(object)
    form = super
    form.tariff_bundle = object.tariff_bundle
    form
  end

  private

  def parent_attributes
    { tariff_bundle: }
  end
end
