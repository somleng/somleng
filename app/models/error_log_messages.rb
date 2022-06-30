ErrorLogMessages = Struct.new(:carrier, :account, :messages, keyword_init: true) do
  delegate :<<, :empty?, to: :messages

  def messages
    @messages ||= []
  end
end
