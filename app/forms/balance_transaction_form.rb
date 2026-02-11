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

  def self.initialize_with(balance_transaction)
    new(
      object: balance_transaction,
      carrier: balance_transaction.carrier,
      description: balance_transaction.description,
      account_id: balance_transaction.account_id,
      type: balance_transaction.type,
      created_by: balance_transaction.created_by,
      amount: balance_transaction.amount
    )
  end

  def save
    return false if invalid?


    if new_record?
      account = carrier.accounts.find(account_id)

      object.attributes = {
        carrier:,
        account:,
        type:,
        amount_cents: InfinitePrecisionMoney.from_amount(amount, account.billing_currency).cents,
        currency: account.billing_currency,
        created_by:
      }
    end

    object.description = description

    object.save!
  end

  def account_options_for_select
    carrier.accounts.map { |item| [ item.name, item.id ] }
  end
end
