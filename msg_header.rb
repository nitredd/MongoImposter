class StandardMessageHeader
  def initialize(message_length: nil, request_id: 0, response_to: 0, op_code: OP_QUERY)
    @message_length = message_length
    @request_id = request_id
    @response_to = response_to
    @op_code = op_code

    @placeholder = placeholder
  end

  def placeholder
    @placeholder
  end

  def placeholder=(placeholder)
    @placeholder = placeholder
  end

  def my_size
    16
  end

  attr_accessor :message_length, :request_id, :response_to, :op_code
#  attr_reader :message_length, :request_id, :response_to, :op_code
#  attr_writer :message_length, :request_id, :response_to, :op_code
end
