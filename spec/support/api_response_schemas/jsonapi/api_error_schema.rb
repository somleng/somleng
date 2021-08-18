module APIResponseSchema
  module JSONAPI
    APIErrorSchema = Dry::Schema.JSON do
      required(:errors).value(:array).each do
        schema do
          optional(:source).hash do
            required(:pointer).filled(:str?)
          end
          required(:title).filled(:str?)
        end
      end
    end
  end
end
