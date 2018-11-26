module FactoryHelpers
  def create_phone_call_with_cdr(*args)
    options = args.extract_options!
    account = options.delete(:account) || create(:account)
    phone_call = create(:phone_call, account: account)
    create(:call_data_record, *args, phone_call: phone_call, **options)
    phone_call
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
