class APIErrorsSerializer < ApplicationSerializer
  def attributes
    {
      message: nil
    }
  end

  def message
    errors(full: true).to_h.values.flatten.to_sentence
  end
end
