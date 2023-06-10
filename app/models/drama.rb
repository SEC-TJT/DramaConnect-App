# frozen_string_literal: true

require_relative 'dramalist'

module DramaConnect
  # Behaviors of the currently logged in account
  class Drama
    attr_reader :id, :name, :rate, :review,:updated_date, :type, :category, :picture_url, :year,:policies # basic info
                :dramalist # full details

    def initialize(info,policy={})
      process_attributes(info['attributes'])
      process_included(info['include'])
      process_policies(policy)
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name  = attributes['name']
      @rate = attributes['rate']
      @review = attributes['review']
      @type = attributes['type']
      @category = attributes['category']
      @picture_url = attributes['picture_url']
      @year = attributes['year']
      @updated_date = attributes['updated_date'].to_s.split(" ")[0]
    end

    def process_included(included)
      @dramalist = Dramalist.new(included['dramalist'])
    end
    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end
  end
end
