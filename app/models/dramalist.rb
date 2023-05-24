module DramaConnect
  class Dramalist
    attr_reader :id, :name, :description,
                :owner, :dramas, :policies # full details

    def initialize(dramalist_info) 
      process_attributes(dramalist_info['attributes'])
      process_relationships(dramalist_info['relationships'])
      process_policies(dramalist_info['policies'])
    end

    attr_reader :id, :name, :repo_url, # basic info
                :owner, :collaborators, :documents, :policies # full details
    private
    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @description = attributes['description']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @dramas = process_documents(relationships['dramas'])
    end

    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end

    def process_documents(documents_info)
      return nil unless documents_info

      documents_info.map { |doc_info| Document.new(doc_info) }
    end
  end
end
