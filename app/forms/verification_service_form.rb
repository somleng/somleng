class VerificationServiceForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  attribute :carrier
  attribute :friendly_name
  attribute :code_length, default: -> { VerificationService::DEFAULT_CODE_LENGTH }
  attribute :account_id
  attribute :account
  attribute :verification_service, default: -> { VerificationService.new }

  validates :code_length,
            presence: true,
            numericality: {
              only_integer: true,
              gteq: VerificationService::VALID_CODE_LENGTHS.min,
              lteq: VerificationService::VALID_CODE_LENGTHS.max
            }

  validates :friendly_name,
            presence: true,
            length: { maximum: VerificationService::MAX_NAME_LENGTH }

  validates :account_id, presence: true, unless: -> { account.present? }

  delegate :persisted?, :new_record?, :id, to: :verification_service

  def self.model_name
    ActiveModel::Name.new(self, nil, "VerificationService")
  end

  def code_length_options_for_select
    VerificationService::VALID_CODE_LENGTHS.map do |code_length|
      ["#{code_length} digits", code_length]
    end
  end

  def account_options_for_select
    accounts_scope.map { |account| [account.name, account.id] }
  end

  def save
    return false if invalid?

    verification_service.carrier = carrier
    verification_service.account = account || find_account
    verification_service.name = friendly_name
    verification_service.code_length = code_length

    verification_service.save!
  end

  private

  def accounts_scope
    carrier.accounts.carrier_managed
  end

  def find_account
    accounts_scope.find(account_id)
  end
end
