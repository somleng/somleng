require "rails_helper"

RSpec.describe HostnameType do
  it "validates hostnames" do
    klass = Struct.new(:hostname) do
      include ActiveModel::Validations

      validates :hostname, hostname: true
    end

    expect(klass.new("foobar.com").valid?).to eq(true)
    expect(klass.new("foo bar.com").valid?).to eq(false)
  end
end
