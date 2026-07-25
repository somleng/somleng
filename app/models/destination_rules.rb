class DestinationRules
  class Validator
    attr_reader :account, :destination, :error_code

    def initialize(account:, destination:)
      @account = account
      @destination = destination
    end

    def valid?
      validate_calling_code

      error_code.blank?
    end

    private

    def validate_calling_code
      return if account.allowed_calling_codes.empty?
      return if account.allowed_calling_codes.include?(Phony.split(destination)[0])

      @error_code = :call_blocked_by_blocked_list
    end
  end

  def valid?(...)
    @validator = Validator.new(...)
    @validator.valid?
  end

  def error_code
    @validator&.error_code
  end
end
