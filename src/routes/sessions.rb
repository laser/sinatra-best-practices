module Sinatra
  module SampleApp
    module Routing
      module Sessions
        def self.registered(app)
          show_login = lambda do
            erb :login
          end

          receive_login = lambda do
            session[:user_id] = params["user_id"]
            redirect '/secrets'
          end

          app.get  '/', &show_login
          app.get  '/sessions/new', &show_login
          app.post '/sessions', &receive_login
        end
      end
    end
  end
end
