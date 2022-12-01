class PhoneNumberConfigurationRules
  attr_reader :error_message, :configuration_context

  def initialize(configuration_context: nil)
    @configuration_context = configuration_context
  end

  def valid?(phone_number:)
    if phone_number.blank?
      @error_message = "Phone number %<value>s does not exist"
    elsif !phone_number.assigned?
      @error_message = "Phone number %<value>s is unassigned"
    elsif configuration_context.present? && configuration_context.call(phone_number)
      @error_message = "Phone number %<value>s is unconfigured"
    elsif !phone_number.enabled?
      @error_message = "Phone number %<value>s is disabled"
    end

    @error_message.blank?
  end
end
