require "rails_helper"

RSpec.describe ImportCSV do
  # Validate account exists

  it "imports a CSV" do
    import = create(
      :import,
      resource_type: "PhoneNumber",
      file: create(:active_storage_attachment, filename: "phone_numbers.csv")
    )

    ImportCSV.call(import)

    expect(import.completed?).to eq(true)
    expect(PhoneNumber.count).to eq(2)
    expect(PhoneNumber.first).to have_attributes(
      number: "1234",
      enabled: false
    )
  end

  it "handles errors" do
    import = create(
      :import,
      resource_type: "PhoneNumber",
      file: create(:active_storage_attachment, filename: "invalid_phone_numbers.csv")
    )

    ImportCSV.call(import)

    expect(import.failed?).to eq(true)
    expect(import.error_message).to be_present
    expect(PhoneNumber.count).to eq(0)
  end
end
