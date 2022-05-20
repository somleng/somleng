require "email_spec"
require "email_spec/rspec"

module EmailSpecHelpers
  def visit_full_link_in_email(asserted_link)
    found_link = links_in_email(current_email).find { |link| link.include?(asserted_link) }
    if found_link.blank?
      raise(
        "No link found matching '#{asserted_link}' in #{Capybara.string(current_email.default_part_body).text}"
      )
    end

    visit(links_in_email(current_email).find { |link| link.include?(asserted_link) })
  end
end

RSpec.configure do |config|
  config.include EmailSpecHelpers, type: :system
end
