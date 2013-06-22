module Sinatra
  module SampleApp
    module Routing
      module Secrets
        def self.registered(app)
          show_secrets = lambda do
            require_logged_in
            erb :secrets
          end

          app.get  '/secrets', &show_secrets
        end
      end
    end
  end
end
