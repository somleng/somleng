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
    phone_number = create(:phone_number, :assigned_to_account)
    message = create(:message, phone_number:, account: phone_number.account, carrier: phone_number.carrier)
    _other_message = create(:message)

    filter = MessageFilter.new(
      resources_scope: Message,
      input_params: {
        filter: {
          phone_number_id: phone_number.id
        }
      }
    )

    result = filter.apply

    expect(result).to contain_exactly(message)
  end
end
