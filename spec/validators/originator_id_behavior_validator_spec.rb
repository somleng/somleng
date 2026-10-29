require "rails_helper"

RSpec.describe OriginatorIDBehaviorValidator do
  it "validates an originator id" do
    validatable_klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :originator_id
      attribute :originator_id_behavior

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :originator_id,
                originator_id_behavior: {
                  passthrough?: ->(record) { record.originator_id_behavior == :passthrough }
                }
    end

    expect(
      validatable_klass.new(
        originator_id: "1234",
        originator_id_behavior: :passthrough
      ).valid?
    ).to be(false)

    expect(
      validatable_klass.new(
        originator_id: nil,
        originator_id_behavior: :override
      ).valid?
    ).to be(false)

    expect(
      validatable_klass.new(
        originator_id: "1234",
        originator_id_behavior: :override
      ).valid?
    ).to be(true)

    expect(
      validatable_klass.new(
        originator_id: nil,
        originator_id_behavior: :passthrough
      ).valid?
    ).to be(true)
  end
end
