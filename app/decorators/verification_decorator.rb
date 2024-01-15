class VerificationDecorator < SimpleDelegator
  STATUSES = %w[
    pending canceled approved expired
  ].freeze

  class << self
    delegate :model_name, :human_attribute_name, to: :Verification

    def statuses
      STATUSES
    end
  end

  def status
    expired? ? "expired" : super
  end

  def to
    phone_number_formatter.format(super, format: :e164)
  end

  def to_formatted
    phone_number_formatter.format(object.to, format: :international)
  end

  def expired?
    object.pending? && object.expired?
  end

  def pending?
    object.pending? && !object.expired?
  end

  def status_color
    if approved?
      :success
    elsif pending?
      :warning
    else
      :danger
    end
  end

  private

  def phone_number_formatter
    @phone_number_formatter ||= PhoneNumberFormatter.new
  end

  def object
    __getobj__
  end
end
