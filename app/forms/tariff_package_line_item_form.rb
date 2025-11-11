class TariffPackageLineItemForm < TariffPlanLineItemForm
  attribute :tariff_package
  attribute :object, default: -> { TariffPackageLineItem.new }

  delegate :carrier, to: :tariff_package

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPackageLineItem")
  end

  def self.initialize_with(object)
    form = super
    form.tariff_package = object.tariff_package
    form
  end

  private

  def parent_attributes
    { tariff_package: }
  end
end
