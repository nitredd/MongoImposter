require './msg_base'
require './msg_types'


class QueryMessage < BaseMessage
  def initialize(header: nil, flags: 0, collection_name: nil, num_skip: 0, num_return: 1, doc: nil, field_selector: nil)
    @header = header
    @flags = flags
    @collection_name = collection_name
    @num_skip = num_skip
    @num_return = num_return
    @doc = doc
    @field_selector = field_selector

    if @header != nil
      @header.op_code = OP_QUERY
    end
    if @doc != nil
      @doc_buffer = @doc.to_bson
    end
  end

  def calculate_message_size
    if @doc_buffer == nil and @doc != nil
      @doc_buffer = @doc.to_bson
    end

    message_length = @doc_buffer.length + @header.my_size + 12 + (@collection_name.length + 1)
    if @header != nil
      @header.message_length = message_length
    end

    message_length
  end

  attr_accessor :flags, :collection_name, :num_skip, :num_return, :doc, :doc_buffer, :field_selector
end
