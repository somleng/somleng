require "rails_helper"

RSpec.describe CreateInteraction do
  it "creates an interaction" do
    phone_call = create(:phone_call, :outbound, to: "855715500234")

    interaction = CreateInteraction.call(
      interactable: phone_call,
      beneficiary_fingerprint: phone_call.to,
      created_at: Time.new(2022, 1, 1)
    )

    expect(interaction).to have_attributes(
      persisted?: true,
      interactable: phone_call,
      account: phone_call.account,
      carrier: phone_call.carrier,
      beneficiary_country_code: "KH",
      created_at: Time.new(2022, 1, 1)
    )
    expect(interaction.beneficiary_fingerprint.to_s).to eq(Digest::SHA256.hexdigest(phone_call.to))
  end

  it "guesses the beneficiary country from the carrier" do
    carrier = create(:carrier, country_code: "CA")
    phone_call = create(:phone_call, :outbound, to: "12505550199", carrier:)

    interaction = CreateInteraction.call(
      interactable: phone_call,
      beneficiary_fingerprint: phone_call.to
    )

    expect(interaction.beneficiary_country_code).to eq("CA")
  end

  it "guesses the beneficiary country" do
    carrier = create(:carrier, country_code: "KH")
    phone_call = create(:phone_call, :outbound, to: "12505550199", carrier:)

    interaction = CreateInteraction.call(
      interactable: phone_call,
      beneficiary_fingerprint: phone_call.to
    )

    expect(interaction.beneficiary_country_code).to eq("US")
  end

  it "handles race conditions" do
    phone_call = create(:phone_call, :outbound)
    existing_interaction = create(:interaction, interactable: phone_call)

    interaction = CreateInteraction.call(
      interactable: existing_interaction.interactable,
      beneficiary_fingerprint: phone_call.to
    )

    expect(interaction).to eq(existing_interaction)
  end
end
