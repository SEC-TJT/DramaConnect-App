# frozen_string_literal: true

require 'roda'

module DramaConnect
  # Web controller for DramaConnect API
  class App < Roda
    route('dramas') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      # GET /dramas/[dra_id]
      routing.get(String) do |dra_id|
        dra_info = GetDrama.new(App.config)
                              .call(@current_account, dra_id)
        drama = Drama.new(dra_info)

        view :drama, locals: {
          current_account: @current_account, drama: drama
        }
      end
      routing.post(String) do |drama_id|
        puts 'test drama delete'
        puts routing.params
        action = routing.params['delete']||routing.params['update']
        puts action
        list_id = routing.params['list_id']
        if action =='delete'
          task=RemoveDrama.new(App.config).call(
            current_account:@current_account,
            dramalist_id:list_id,
            drama_id:drama_id
          )
          flash[:notice] = task.to_h['message']
        elsif action=='update'
          puts 'drama_id:',drama_id
          drama_data = Form::NewDrama.new.call(routing.params)
          if drama_data.failure?
            flash[:error] = Form.message_values(drama_data)
            routing.halt
          end

          task=UpdateDrama.new(App.config).call(
            current_account:@current_account,
            list_id:list_id,
            drama_id:drama_id,
            drama_data:drama_data.to_h
          )
          flash[:notice] = task.to_h['message']
        end


      rescue StandardError
        flash[:error] = 'Could not delete the drama'
      ensure
        routing.redirect '/dramalists'
      end
    end
  end
end
