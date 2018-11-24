class ApplicationRequestSchema
  class_attribute :schema

  def self.define_schema(&block)
    self.schema = Dry::Validation.Params do
      configure do
        config.messages = :i18n
        config.type_specs = true
      end

      instance_eval(&block)
    end
  end

  module Types
    include Dry::Types.module

    HTTPMethod = String.constructor do |http_method|
      http_method.upcase if http_method.present?
    end
  end
end
