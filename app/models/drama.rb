# frozen_string_literal: true

require_relative 'dramalist'

module DramaConnect
  # Behaviors of the currently logged in account
  class Drama
    attr_reader :id, :name, # basic info
                :dramalist # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id             = attributes['id']
      @filename       = attributes['name']
    end

    def process_included(included)
      @dramalist = Dramalist.new(included['dramalist'])
    end
  end
end
