class UpdatePhoneNumberConfiguration < ApplicationWorkflow
  attr_reader :phone_number, :configuration_params

  def initialize(phone_number, configuration = {})
    @phone_number = phone_number
    @configuration_params = configuration
  end

  def call
    build_configuration.save!
  end

  private

  def build_configuration
    configuration = phone_number.configuration || phone_number.build_configuration
    configuration.attributes = configuration_params
    configuration
  end
end
