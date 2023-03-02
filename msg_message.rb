require './msg_base'
require './msg_types'


class MessageMessage < BaseMessage
  def initialize(header: nil, flags: 1, kind: 0, sections: [])
    @header = header
    @flags = flags
    @sections = sections

    if @header != nil
      @header.op_code = OP_MSG
    end
  end

  def calculate_message_size
    message_length = @header.my_size + 4

    @sections.each do |iter_section|
      message_length += iter_section.calculate_message_size
    end

    message_length += 4  #For CRC, assuming non-TLS

        if @header != nil
      @header.message_length = message_length
    end
    message_length
  end

  #TODO - Create a docs custom accessor method to return the section 0 document

  attr_accessor :flags, :sections
end