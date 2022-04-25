class CreateInteraction < ApplicationWorkflow
  attr_reader :interactable, :beneficiary, :beneficiary_country

  def initialize(params)
    @interactable = params.fetch(:interactable)
    @beneficiary = params.fetch(:beneficiary)
  end

  def call
    Interaction.create_or_find_by!(interactable:) do |interaction|
      interaction.attributes = {
        carrier: interactable.carrier,
        account: interactable.account,
        beneficiary_country_code: interactable.beneficiary_country_code,
        beneficiary_fingerprint: beneficiary
      }
    end
  end
end
