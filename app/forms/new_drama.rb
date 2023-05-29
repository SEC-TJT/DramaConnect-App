# frozen_string_literal: true

require_relative 'form_base'

module DramaConnect
  module Form
    class NewDrama < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_drama.yml')

      params do
        required(:name).filled
        required(:rate).filled
        required(:review).filled
        
        required(:picture_url).value(:string)
        required(:year).value(:integer)
        required(:category).value(:string)
        required(:type).value(:string)
      end
    end
  end
end
