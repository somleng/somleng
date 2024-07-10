module Services
  class RequestErrorsSerializer < ApplicationSerializer
    def attributes
      {
        message: nil
      }
    end

    def message
      errors(full: true).map(&:text).to_sentence
    end
  end
end
