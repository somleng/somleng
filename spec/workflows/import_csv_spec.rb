require "rails_helper"

RSpec.describe ImportCSV do
  it "imports a CSV" do
    carrier = create(:carrier, billing_currency: "USD")
    import = create(
      :import,
      carrier:,
      resource_type: "PhoneNumber",
      file: create(:active_storage_attachment, filename: "phone_numbers.csv")
    )

    ImportCSV.call(import)

    expect(import.completed?).to eq(true)
  end

  it "handles invalid CSVs" do
    import = create(
      :import,
      resource_type: "PhoneNumber",
      file: create(:active_storage_attachment, filename: "invalid_phone_numbers.csv")
    )

    ImportCSV.call(import)

    expect(import.failed?).to eq(true)
    expect(import.error_message).to be_present
  end
end
