class CreateMessage < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    message = Message.create!(params)
    create_interaction(message)
    message
  end

  private

  def create_interaction(message)
    Interaction.create_or_find_by!(interactable: message) do |interaction|
      interaction.attributes = {
        carrier: message.carrier,
        account: message.account,
        beneficiary_country_code: message.beneficiary_country_code,
        beneficiary_fingerprint: message.beneficiary_fingerprint
      }
    end
  end
end
