class ProcessRatingEngineCDRJob < ApplicationJob
  CDR = Data.define(
    :id,
    :origin_id,
    :balance_transaction_id,
    :category,
    :account,
    :amount,
    :message,
    :phone_call,
    :interaction
  )

  class PhoneCallNotFoundError < StandardError; end

  retry_on(
    PhoneCallNotFoundError,
    wait: :polynomially_longer,
    attempts: 3
  )

  def perform(cdr_record)
    cdr = parse_cdr(cdr_record)
    ApplicationRecord.transaction do
      create_balance_transaction(cdr)
      update_interaction(cdr)
    end
  end

  private

  def parse_cdr(cdr_record)
    cdr = RatingEngineClient::CDR.new(**cdr_record.symbolize_keys)
    account = Account.find(cdr.account_id)
    category = TariffScheduleCategoryType.new.cast(cdr.category)
    message = account.messages.find_by(id: cdr.origin_id) if category.tariff_category.message?

    if category.tariff_category.call?
      phone_call = account.phone_calls.find_by(external_id: cdr.origin_id)
      raise(PhoneCallNotFoundError) if phone_call.blank?
    end

    CDR.new(
      id: cdr.id,
      origin_id: cdr.origin_id,
      balance_transaction_id: cdr.balance_transaction_id,
      category:,
      account:,
      amount: InfinitePrecisionMoney.new(cdr.cost, account.billing_currency),
      message:,
      phone_call:,
      interaction: message || phone_call
    )
  end

  def create_balance_transaction(cdr)
    BalanceTransaction.create_or_find_by!(external_id: cdr.id) do |balance_transaction|
      balance_transaction.account = cdr.account
      balance_transaction.carrier_id = cdr.account.carrier_id
      balance_transaction.type = :charge
      balance_transaction.amount_cents = -cdr.amount.cents
      balance_transaction.currency = cdr.amount.currency
      balance_transaction.charge_category = cdr.category.value
      balance_transaction.message = cdr.message
      balance_transaction.phone_call = cdr.phone_call
    end
  end

  def update_interaction(cdr)
    cdr.interaction&.update_columns(price_cents: cdr.amount.cents, price_unit: cdr.amount.currency.to_s)
  end
end
