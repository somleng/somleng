class PhoneNumberPlanForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :phone_number
  attribute :account
  attribute :phone_number_plan, default: -> { PhoneNumberPlan.new }

  delegate :persisted?, :new_record?, :id, to: :phone_number_plan
  delegate :id, to: :phone_number, prefix: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "PhoneNumberPlan")
  end

  def save
    return false if invalid?

    self.phone_number_plan = CreatePhoneNumberPlan.call(phone_number:, account:)
  end
end
