class VerificationCodeGenerator
  def generate_code(code_length:)
    SecureRandom.random_number(10**code_length).to_s.rjust(code_length, "0")
  end
end
