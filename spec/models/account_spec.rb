require 'rails_helper'

describe Account do
  describe "associations" do
    it { is_expected.to have_one(:access_token) }
    it { is_expected.to have_many(:phone_calls) }
  end
end
