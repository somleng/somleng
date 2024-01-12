class VerificationService < ApplicationRecord
  belongs_to :carrier
  belongs_to :account

  has_many :verifications

  def default_template(code:, locale:, country_code:)
    VerificationTemplate.new(friendly_name: name, country_code:, locale:, code:)
  end
end
