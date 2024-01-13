class VerificationService < ApplicationRecord
  MAX_NAME_LENGTH = 30
  VALID_CODE_LENGTHS = (4..10)
  DEFAULT_CODE_LENGTH = 6

  belongs_to :carrier
  belongs_to :account

  has_many :verifications

  validates :code_length,
            presence: true,
            numericality: {
              only_integer: true,
              gteq: VALID_CODE_LENGTHS.min,
              lteq: VALID_CODE_LENGTHS.max
            }

  validates :name,
            presence: true,
            length: { maximum: MAX_NAME_LENGTH }

  def default_template(**)
    VerificationTemplate.new(friendly_name: name, **)
  end
end
