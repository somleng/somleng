class AccountTariffPackageForm < TariffPackageLineItemForm
  attribute :account
  attribute :object, default: -> { AccountTariffPackage.new }

  delegate :carrier, to: :account

  def self.model_name
    ActiveModel::Name.new(self, nil, "AccountTariffPackage")
  end

  def self.initialize_with(object)
    form = super
    form.account = object.account
    form
  end

  private

  def parent_attributes
    { account: }
  end
end
