require "rails_helper"

RSpec.describe InfinitePrecisionMoney do
  it "formats with default infinite precision" do
    money = InfinitePrecisionMoney.from_amount(1234.56, "USD")
    expect(money.format).to eq("$1,234.56")

    money = InfinitePrecisionMoney.from_amount(1234.56789, "USD")
    expect(money.format).to eq("$1,234.56789")

    money = InfinitePrecisionMoney.from_amount(1317.18, "VND")
    expect(money.format).to eq("₫1,317.18")

    money = InfinitePrecisionMoney.from_amount(1317.18, "USD")
    expect(money.format(decimal_mark: ",", thousands_separator: ".")).to eq("$1.317,18")
  end
end
