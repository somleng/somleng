require "rails_helper"

RSpec.describe SquishedStringType do
  it "handles redundant whitespace in strings" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :my_string, SquishedStringType.new
    end

    expect(klass.new(my_string: "  Foo  Bar ").my_string).to eq("Foo Bar")
  end
end
