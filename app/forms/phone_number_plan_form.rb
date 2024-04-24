class PhoneNumberPlanForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :phone_number
  attribute :account
  attribute :account_id
  attribute :phone_number_plan, default: -> { PhoneNumberPlan.new }

  delegate :persisted?, :new_record?, :id, to: :phone_number_plan
  delegate :id, to: :phone_number, prefix: true

  validates :account_id, presence: true, if: -> { account.blank? }

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumberPlan")
  end

  def save
    return false if invalid?

    phone_number_plan.phone_number = phone_number
    phone_number_plan.account = account || find_account

    phone_number_plan.save!
  end

  def account_options_for_select
    accounts_scope.map { |account| [ account.name, account.id ] }
  end

  def find_account
    accounts_scope.find(account_id)
  end

  def accounts_scope
    carrier.accounts.carrier_managed.where(billing_currency: phone_number.currency)
  end
end
