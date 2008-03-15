class Mechaflickr
  class Model
    attr_reader :id
    
    def initialize(id)
      @id = id.to_i
      raise "Invalid id: #{id}" if @id == 0
    end
  end
end