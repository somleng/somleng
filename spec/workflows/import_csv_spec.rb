require "rails_helper"

RSpec.describe ImportCSV do
  it "imports a CSV" do
    carrier = create(:carrier)
    account = create(:account, carrier:, id: "ccdb7202-e487-436c-b964-c3acb7884c8f")
    import = create(
      :import,
      carrier:,
      resource_type: "PhoneNumber",
      file: create(:active_storage_attachment, filename: "phone_numbers_with_account.csv")
    )

    ImportCSV.call(import)

    expect(import.completed?).to eq(true)
    expect(PhoneNumber.count).to eq(2)
    expect(PhoneNumber.first).to have_attributes(
      number: "1234",
      enabled: false,
      account:
    )
    expect(PhoneNumber.last).to have_attributes(
      number: "2345",
      enabled: true,
      account: nil
    )
  end

  it "handles invalid phone numbers" do
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

  it "handles invalid accounts" do
    import = create(
      :import,
      resource_type: "PhoneNumber",
      file: create(:active_storage_attachment, filename: "invalid_account_phone_numbers.csv")
    )

    ImportCSV.call(import)

    expect(import.failed?).to eq(true)
    expect(import.error_message).to match("account_sid is invalid")
    expect(PhoneNumber.count).to eq(0)
  end
end
