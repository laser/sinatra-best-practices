module Sinatra
  module SampleApp
    module Helpers
      def require_logged_in
        redirect('/sessions/new') unless is_authenticated?
      end

      def is_authenticated?
        return !!session[:user_id]
      end
    end
  end
end
