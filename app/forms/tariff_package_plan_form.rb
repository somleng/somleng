class TariffPackagePlanForm < TariffPlanAssignmentForm
  attribute :package
  attribute :object, default: -> { TariffPackagePlan.new }

  delegate :carrier, to: :package

  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffPackagePlan")
  end

  def self.initialize_with(object)
    form = super
    form.package = object.package
    form
  end

  private

  def parent_attributes
    { package: }
  end
end
