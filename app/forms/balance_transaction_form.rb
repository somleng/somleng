class BalanceTransactionForm < ApplicationForm
  attribute :object, default: -> { BalanceTransaction.new }
  attribute :carrier
  attribute :account_id
  attribute :type
  attribute :amount, :decimal
  attribute :description
  attribute :created_by

  enumerize :type, in: [ :topup, :adjustment ]

  delegate :new_record?, :persisted?, :id, to: :object

  validates :account_id, presence: true
  validates :type, presence: true
  validates :amount, presence: true, numericality: {
    greater_than: 0, if: ->(form) { form.type == "topup" }
  }

  validates :amount, numericality: {
    greater_than: -10**10,
    less_than: 10**10,
    other_than: 0
  }

  def self.model_name
    ActiveModel::Name.new(self, nil, "BalanceTransaction")
  end

  def save
    return false if invalid?

    account = carrier.accounts.find(account_id)

    object.carrier = carrier
    object.account = account
    object.type = type
    object.amount_cents = InfinitePrecisionMoney.from_amount(amount, account.billing_currency).cents
    object.currency = account.billing_currency
    object.description = description
    object.created_by = created_by
    object.save!
  end

  def account_options_for_select
    carrier.accounts.map { |item| [ item.name, item.id ] }
  end
end
