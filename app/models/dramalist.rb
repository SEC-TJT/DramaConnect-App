module DramaConnect
  class Dramalist
    attr_reader :id, :name, :description,:updated_date,
                :owner, :dramas, :policies # full details

    def initialize(dramalist_info) 
      process_attributes(dramalist_info['attributes'])
      process_relationships(dramalist_info['relationships'])
      process_policies(dramalist_info['policies'])
    end

    attr_reader :id, :name, :repo_url, # basic info
                :owner, :visitors, :dramas, :policies # full details
    private
    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @description = attributes['description']
      @updated_date = attributes['updated_date'].to_s.split(" ")[0]
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @dramas = process_dramas(relationships['dramas'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies.to_h)
    end

    def process_dramas(dramas_info)
      return nil unless dramas_info

      dramas_info.map { |doc_info| Drama.new(doc_info) }
    end
  end
end
