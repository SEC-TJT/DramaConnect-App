module DramaConnect
  class Dramalist
    attr_reader :id, :name, :description
    def initialize(dramalist_info) 
      @id = dramalist_info['attributes']['id']
      @name = dramalist_info['attributes']['name']
      @description = dramalist_info['attributes']['description']
    end
  end
end
