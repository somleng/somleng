require "rails_helper"

RSpec.describe MessageFilter do
  it "filters by status" do
    initiated_message = create(:message, :initiated)
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

    expect(result).to match_array([initiated_message])
  end
end
