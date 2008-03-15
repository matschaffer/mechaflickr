class Mechaflickr
  class Photo
    attr_reader :id
    
    def initialize(id)
      @id = id.to_i
      raise "Invalid photo id: #{id}" if @id == 0
    end
  end
end