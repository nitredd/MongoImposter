class MessageMessageSection
  def initialize(kind: 0, doc: nil, checksum: 0)
    @kind = kind
    @doc = doc
    @checksum = checksum

    if @doc != nil
      @doc_buffer = @doc.to_bson
    end
  end

  def calculate_message_size
    if @doc_buffer == nil and @doc != nil
      @doc_buffer = @doc.to_bson
    end

    message_length = 1 + @doc_buffer.length
    message_length
  end

  attr_accessor :kind, :doc, :doc_buffer, :checksum
end
