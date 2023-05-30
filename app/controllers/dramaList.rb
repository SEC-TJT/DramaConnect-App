# frozen_string_literal: true

require 'roda'

module DramaConnect
  # Web controller for DramaConnect API
  class App < Roda
    route('dramalists') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @dramalists_route = '/dramalists'

        routing.get 'dramalists', String, 'dramas', String do |list_id, drama_id|
          # Your code logic for handling the request goes her
          puts list_id,drama_id

          drama_info = GetDrama.new(App.config).call(
              @current_account, list_id,drama_id
            )
          puts "Drama Info is:",drama_info
          drama=Drama.new(drama_info);
          puts drama.review
          view :drama,locals: {
              current_account: @current_account,
              drama:drama,
              list_id:list_id
            }
            # "Fetching drama with list_id #{list_id} and drama_id #{drama_id}"
        end

        routing.on(String) do |list_id|
          @dramalist_route = "#{@dramalists_route}/#{list_id}"

          # GET /dramalists/[list_id]
          routing.get do
            puts "Hello"
            list_info = GetDramas.new(App.config).call(
              @current_account, list_id
            )
            dramalist = Dramalist.new(list_info)

            view :dramalist, locals: {
              current_account: @current_account, dramalist: dramalist
            }
          rescue StandardError => e
            puts "#{e.inspect}\n#{e.backtrace}"
            flash[:error] = 'Dramalist not found'
            routing.redirect @dramalists_route
          end


          # POST /dramalists/[list_id]/visitors
          routing.post('visitors') do
            action = routing.params['action']
            visitors_info = Form::VisitorEmail.new.call(routing.params)
            if visitors_info.failure?
              flash[:error] = Form.validation_errors(visitors_info)
              routing.halt
            end

            task_list = {
              'add' => { service: AddVisitor,
                         message: 'Added new visitors to dramalist' },
              'remove' => { service: RemoveVisitor,
                            message: 'Removed visitors from dramalist' }
            }

            task = task_list[action]
            task[:service].new(App.config).call(
              current_account: @current_account,
              visitor: visitors_info,
              dramalist_id: list_id
            )
            flash[:notice] = task[:message]

          rescue StandardError
            flash[:error] = 'Could not find visitors'
          ensure
            routing.redirect @dramalist_route
          end

          
          routing.on('dramas') do
            # get /dramalists/[list_id]/dramas/[drama_id]
            # routing.on(String) do |drama_id|
            #   @drama_route = "#{@dramalists_route}/#{list_id}/dramas/#{drama_id}"
            #   routing.get do
            #     view :drama
            #   end
            # end
            # POST /dramalists/[list_id]/dramas/
            routing.post do
              puts routing.params
              drama_data = Form::NewDrama.new.call(routing.params)
              if drama_data.failure?
                flash[:error] = Form.message_values(drama_data)
                routing.halt
              end

              CreateNewDrama.new(App.config).call(
                current_account: @current_account,
                dramalist_id: list_id,
                drama_data: drama_data.to_h
              )

              flash[:notice] = 'Your drama was added'
            rescue StandardError => error
              puts error.inspect
              puts error.backtrace
              flash[:error] = 'Could not add drama'
            ensure
              routing.redirect @dramalist_route
            end
          end

          # Delete /dramalists/[list_id]
          routing.post do 
            action = routing.params['delete']
            if action =='delete'
              task=RemoveDramalist.new(App.config).call(
                current_account:@current_account,
                dramalist_id:list_id
              )
              flash[:notice] = task.to_h['message']
            end
            
          rescue StandardError
            flash[:error] = 'Could not delete the dramalist'
          ensure
            routing.redirect @dramalists_route
          end

        end

        # GET /dramalists/
        routing.get do
          dramalists = GetAllDramalists.new(App.config).call(@current_account)
          view :account, locals: {
            current_account: @current_account, dramalists: dramalists
          }
        end

        # POST /dramalists/
        routing.post do
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "LIST: #{routing.params}"
          dramalist_data = Form::NewDramalist.new.call(routing.params)
          if dramalist_data.failure?
            flash[:error] = Form.message_values(dramalist_data)
            routing.halt
          end

          CreateNewDramalist.new(App.config).call(
            current_account: @current_account,
            dramalist_data: dramalist_data.to_h
          )

          flash[:notice] = 'Add dramas and visitors to your new dramalist'
        rescue StandardError => e
          puts "FAILURE Creating Dramalist: #{e.inspect}"
          flash[:error] = 'Could not create dramalist'
        ensure
          routing.redirect @dramalists_route
        end
      end
    end
  end
end
