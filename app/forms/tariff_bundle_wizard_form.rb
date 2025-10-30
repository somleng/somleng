class TariffBundleWizardForm < ApplicationForm
  attribute :carrier
  attribute :name
  attribute :description
  attribute :outbound_calls_tariff
  attribute :inbound_calls_tariff
  attribute :outbound_messages_tariff
  attribute :inbound_messages_tariff


  def self.model_name
    ActiveModel::Name.new(self, nil, "TariffBundle")
  end
end
