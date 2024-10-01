require "rails_helper"

RSpec.describe AggregateDataQuery do
  it "handles key digests" do
    expect(build_aggregate_data(key: [ "foo" ]).id).to eq(Digest::SHA256.hexdigest("foo"))
    expect(build_aggregate_data(key: [ "FOO", "BAR" ]).id).to eq(Digest::SHA256.hexdigest("foo:bar"))
    expect(build_aggregate_data(key: [ "foo", nil ]).id).to eq(Digest::SHA256.hexdigest("foo"))
  end

  def build_aggregate_data(**options)
    AggregateData.new(
      key: [ "foo" ],
      groups: [ build_group(name: "foo", column: "foo") ],
      sequence_number: 1,
      value: 1,
      **options
    )
  end

  def build_group(**)
    Class.new(Struct.new(:name, :column, keyword_init: true)).new(**)
  end
end
