require 'mechaflickr/model'

class Mechaflickr
  class Photoset < Model
    def initialize(id, url)
      super(id)
      @url = url
    end
  end
end