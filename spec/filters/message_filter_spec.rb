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

    expect(result).to match_array([sending_message])
  end
end
