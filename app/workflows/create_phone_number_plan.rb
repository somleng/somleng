class CreatePhoneNumberPlan < ApplicationWorkflow
  attr_reader :configuration_params, :params

  def initialize(configuration: {}, **params)
    @configuration_params = configuration
    @params = params
  end

  def call
    build_configuration
    create_plan
  end

  private

  def create_plan
    PhoneNumberPlan.create!(params)
  end

  def build_configuration
    return if configuration_params.blank?

    configuration = phone_number.configuration || phone_number.build_configuration
    configuration.attributes = configuration_params
    configuration
  end

  def phone_number
    params.fetch(:phone_number)
  end
end
