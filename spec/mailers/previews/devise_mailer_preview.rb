class DeviseMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    user = User.last
    DeviseMailer.confirmation_instructions(user, "faketoken")
  end

  def invitation_instructions
    user = User.last
    DeviseMailer.invitation_instructions(user, "faketoken")
  end

  def reset_password_instructions
    user = User.last
    DeviseMailer.reset_password_instructions(user, "faketoken")
  end

  def unlock_instructions
    user = User.last
    DeviseMailer.unlock_instructions(user, "faketoken")
  end
end
