require "email_spec"
require "email_spec/rspec"

module EmailSpecHelpers
  def visit_full_link_in_email(title)
    link = Capybara.string(current_email.default_part_body).find_link(title)
    visit(link[:href])
  end
end

RSpec.configure do |config|
  config.include EmailSpecHelpers, type: :system
end
