require "rails_helper"

RSpec.describe DialString do
  it "handles trunk prefixes" do
    sip_trunk = create(
      :outbound_sip_trunk,
      host: "96.9.66.131",
      trunk_prefix: true
    )

    result = DialString.new(
      outbound_sip_trunk: sip_trunk,
      destination: "855715100970"
    ).to_s

    expect(result).to eq("0715100970@96.9.66.131")
  end

  it "handles dial string prefixes" do
    sip_trunk = create(
      :outbound_sip_trunk,
      host: "96.9.66.131",
      dial_string_prefix: "69980"
    )

    result = DialString.new(
      outbound_sip_trunk: sip_trunk,
      destination: "855715100970"
    ).to_s

    expect(result).to eq("69980855715100970@96.9.66.131")
  end
end
