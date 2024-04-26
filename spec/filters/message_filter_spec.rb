require "rails_helper"

RSpec.describe MessageFilter do
  it "filters by status" do
    sending_message = create(:message, :sending)
    _sent_messaage = create(:message, :sent)

    filter = MessageFilter.new(
      resources_scope: Message,
      input_params: {
        filter: {
          status: "sending"
        }
      }
    )

    result = filter.apply

    expect(result).to eq([ sending_message ])
  end

  it "filters by phone number" do
    carrier = create(:carrier)
    account = create(:account, carrier:)
    incoming_phone_number = create(:incoming_phone_number, account:)
    message = create(:message, incoming_phone_number:, account:, carrier:)
    _other_message = create(:message)

    filter = MessageFilter.new(
      resources_scope: Message,
      input_params: {
        filter: {
          phone_number_id: incoming_phone_number.id
        }
      }
    )

    result = filter.apply

    expect(result).to contain_exactly(message)
  end
end
