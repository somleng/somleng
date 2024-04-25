class PhoneNumberConfigurationRules
  attr_reader :error_message

  def valid?(incoming_phone_number)
    if incoming_phone_number.blank?
      @error_message = "Phone number %<value>s does not exist."
    elsif block_given? && !yield
      @error_message = "Phone number %<value>s is unconfigured."
    end

    @error_message.blank?
  end
end
