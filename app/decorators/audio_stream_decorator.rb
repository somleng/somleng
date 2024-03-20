class AudioStreamDecorator < SimpleDelegator
  def sid
    object.id
  end

  private

  def object
    __getobj__
  end
end
