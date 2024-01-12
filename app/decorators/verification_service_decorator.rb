class VerificationServiceDecorator < SimpleDelegator
  def sample_message
    code = verification_code_generator.generate_code(code_length: object.code_length)
    object.default_template(code:, locale: :en).render_message
  end

  private

  def verification_code_generator
    VerificationCodeGenerator.new
  end

  def object
    __getobj__
  end
end
