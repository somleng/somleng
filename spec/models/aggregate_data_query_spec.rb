require "rails_helper"

RSpec.describe AggregateDataQuery do
  it "handles different having operations" do
    carrier = create(:carrier)
    create(:phone_number, carrier:, number: "855715100800", iso_country_code: "KH")
    create(:phone_number, carrier:, number: "855715100801", iso_country_code: "KH")
    create(:phone_number, carrier:, number: "12513095500", iso_country_code: "US")

    expect(apply_phone_number_query).to contain_exactly(
      have_attributes(key: "KH", value: 2),
      have_attributes(key: "US", value: 1)
    )

    expect(apply_phone_number_query(having: { count: { eq: 2 } })).to contain_exactly(
      have_attributes(key: "KH", value: 2)
    )

    expect(apply_phone_number_query(having: { count: { neq: 2 } })).to contain_exactly(
      have_attributes(key: "US", value: 1)
    )

    expect(apply_phone_number_query(having: { count: { gt: 1 } })).to contain_exactly(
      have_attributes(key: "KH", value: 2)
    )

    expect(apply_phone_number_query(having: { count: { gteq: 2 } })).to contain_exactly(
      have_attributes(key: "KH", value: 2)
    )

    expect(apply_phone_number_query(having: { count: { lt: 2 } })).to contain_exactly(
      have_attributes(key: "US", value: 1)
    )

    expect(apply_phone_number_query(having: { count: { lteq: 1 } })).to contain_exactly(
      have_attributes(key: "US", value: 1)
    )
  end

  def build_group(**)
    Class.new(Struct.new(:name, :column, keyword_init: true)).new(**)
  end

  def apply_phone_number_query(**)
    build_query(groups: [ build_country_group ], **).apply(PhoneNumber)
  end

  def build_country_group
    build_group(name: "country", column: :iso_country_code)
  end

  def build_query(**)
    AggregateDataQuery.new(**)
  end
end
