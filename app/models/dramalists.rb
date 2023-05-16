require_relative 'dramalist'

module DramaConnect
  class Dramalists
    attr_reader :all
    def initialize(dramalists)
      @all=dramalists.map do |dramalist|
        DramaConnect::Dramalist.new(dramalist)
      end
    end
  end
end
