class VerificationDecorator < SimpleDelegator
  def status
    return "expired" if pending? && expired?

    super
  end

  def to
    phone_number_formatter.format(super, format: :e164)
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end
end
