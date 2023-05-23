# frozen_string_literal: true

require_relative 'form_base'

module DramaConnect
  module Form
    class NewDramalist < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_dramalist.yml')

      params do
        required(:name).filled
        required(:description).filled
      end
    end
  end
end
