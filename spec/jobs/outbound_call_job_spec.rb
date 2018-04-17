# frozen_string_literal: true

require 'rails_helper'

describe OutboundCallJob do
  describe '#perform(phone_call_id)' do
    it 'initiates an outbound call' do
      phone_call_id = '12345'
      phone_call = instance_double(PhoneCall, id: phone_call_id)
      allow(
        PhoneCall
      ).to receive(:find).with(phone_call_id).and_return(phone_call)
      allow(phone_call).to receive(:initiate_outbound_call!)

      expect(phone_call).to receive(:initiate_outbound_call!)
      subject.perform(phone_call.id)
    end
  end

  include_examples "aws_sqs_queue_url"
end
