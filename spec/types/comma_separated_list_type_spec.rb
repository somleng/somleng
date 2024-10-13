require "rails_helper"

RSpec.describe CommaSeparatedListType do
  it "handles comma separated lists" do
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :list, CommaSeparatedListType.new
    end

    expect(klass.new(list: "").list).to eq([])
    expect(klass.new(list: "foo, bar").list).to eq([ "foo", "bar" ])
    expect(klass.new(list: "foo, bar, bar").list).to eq([ "foo", "bar" ])
    expect(klass.new(list: "foo, , ,").list).to eq([ "foo" ])
  end
end
