require "rails_helper"

RSpec.describe URLValidator do
  it "validates URLs" do
    validator = URLValidator.new

    expect(validator.valid?("https://www.example.com")).to eq(true)
    expect(validator.valid?("http://www.example.com")).to eq(false)
    expect(validator.valid?("www.example.com")).to eq(false)
    expect(validator.valid?("foobar")).to eq(false)

    expect(URLValidator.new(allow_http: true).valid?("http://www.example.com")).to eq(true)
    expect(URLValidator.new.valid?(nil)).to eq(false)
    expect(URLValidator.new(allow_blank: true).valid?(nil)).to eq(true)
  end

  it "validates IP addresses" do
    validator = URLValidator.new(allow_http: true)

    expect(validator.valid?("http://93.184.216.34")).to eq(true)
    expect(validator.valid?("http://localhost")).to eq(false)
    expect(validator.valid?("http://127.0.0.1")).to eq(false)
    expect(validator.valid?("http://10.0.0.5")).to eq(false)
    expect(validator.valid?("http://192.168.1.1")).to eq(false)
  end
end
