require "rails_helper"

RSpec.describe FuzzySearch do
  it "returns records that approximately match the search term" do
    create(:carrier, name: "Acme Telecom")
    create(:carrier, name: "Global Communications")
    fuzzy_search = FuzzySearch.new(Carrier.all, column: :name)

    results = fuzzy_search.apply("CME")

    expect(results).to contain_exactly(
      have_attributes(name: "Acme Telecom")
    )

    expect(FuzzySearch.new(Carrier.all, column: :name).apply("' OR '1'='1")).to be_empty
    expect(FuzzySearch.new(Carrier.all, column: :name).apply("%Telecom%")).to be_empty
  end
end
