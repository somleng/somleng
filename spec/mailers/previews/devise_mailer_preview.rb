class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    user = User.last
    DeviseMailer.confirmation_instructions(user, "faketoken")
  end
end
