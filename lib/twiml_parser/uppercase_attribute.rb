module TwiMLParser
  class UppercaseAttribute
    def cast(value)
      value.to_s.upcase
    end
  end
end
