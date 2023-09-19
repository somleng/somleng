require "rails_helper"

RSpec.describe ExportCSV do
  it "exports a CSV" do
    carrier = create(:carrier)
    user = create(:user, :carrier, carrier:)
    export = create(
      :export,
      resource_type: "PhoneCall",
      user:,
      scoped_to: { carrier_id: carrier.id }
    )

    phone_call = create(:phone_call, carrier:)
    _other_phone_call = create(:phone_call)

    ExportCSV.call(export)

    expect(export.file.attached?).to eq(true)
    expect(export.status_message).to eq("Done")
    expect(export.file.blob.filename).to eq(export.name)
    expect(export.file.blob.content_type).to eq("text/csv")
    csv_data = CSV.parse(export.file.download, headers: true)
    expect(csv_data["sid"]).to eq([phone_call.id])
  end
end
