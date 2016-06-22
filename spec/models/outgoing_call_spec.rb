require 'rails_helper'

describe OutgoingCall do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end
end
