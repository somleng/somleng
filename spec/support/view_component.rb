module ViewComponentHelpers
  attr_reader :component, :rendered

  def render_component(*args, &block)
    @component = described_class.new(*args)
    @rendered = render_inline(component, &block)
  end
end

RSpec.configure do |config|
  config.include ViewComponentHelpers, type: :component
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
end
