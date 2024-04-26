class CreatePhoneNumberPlan < ApplicationWorkflow
  attr_reader :phone_number, :account, :phone_number_formatter

  def initialize(phone_number:, account:, phone_number_formatter: PhoneNumberFormatter.new)
    @phone_number = phone_number
    @account = account
    @phone_number_formatter = phone_number_formatter
  end

  def call
    plan = build_plan
    build_incoming_phone_number_for(plan)
    plan.save!
    plan
  end

  private

  def build_plan
    PhoneNumberPlan.new(
      phone_number:,
      account:,
      number: phone_number.number,
      carrier: phone_number.carrier,
      amount: phone_number.price,
    )
  end

  def build_incoming_phone_number_for(plan)
    plan.build_incoming_phone_number(
      account:,
      phone_number:,
      account_type: account.type,
      number: phone_number.number,
      friendly_name: phone_number_formatter.format(phone_number.number, format: :national)
    )
  end
end
