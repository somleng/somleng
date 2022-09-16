require "rails_helper"

RSpec.describe DialString do
  it "handles trunk prefixes" do
    sip_trunk = create(
      :sip_trunk,
      outbound_host: "96.9.66.131",
      outbound_trunk_prefix: true
    )

    result = DialString.new(
      sip_trunk:,
      destination: "2609702120780"
    ).to_s

    expect(result).to eq("09702120780@96.9.66.131")
  end

  it "handles dial string prefixes" do
    sip_trunk = create(
      :sip_trunk,
      outbound_host: "96.9.66.131",
      outbound_dial_string_prefix: "69980"
    )

    result = DialString.new(
      sip_trunk:,
      destination: "855715100970"
    ).to_s

    expect(result).to eq("69980855715100970@96.9.66.131")
  end

  it "handles plus prefixes" do
    sip_trunk = create(
      :sip_trunk,
      outbound_host: "96.9.66.131",
      outbound_plus_prefix: true
    )

    result = DialString.new(
      sip_trunk:,
      destination: "855715100970"
    ).to_s

    expect(result).to eq("+855715100970@96.9.66.131")
  end
end
