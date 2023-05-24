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
      end
    end
  end
end
