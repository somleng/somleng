require "rails_helper"

RSpec.describe MaskedContentComponent, type: :component do
  it "renders masked content" do
    render_component(raw_content: "api-key")

    expect(rendered).to have_selector("code", text: "********************")
  end

  it "renders masked content with extra options" do
    render_component(raw_content: "api-xzy", start_from: 4, length: 10)

    expect(rendered).to have_selector("code", text: "api-**********")
  end
end
