Sinatra Best Practices: Part One
================================

While Sinatra’s one-file approach may work well for your one-off, smaller
application - it can quickly become a mess as you add on multiple routes,
route-handlers, helpers, and configuration. So what’s a programmer to do?

In reading Sinatra’s documentation I’ve found a few morsels that have enabled
us to split our otherwise-monolithic (I realize this term is becoming a cliché,
but given the single-file nature of Sinatra-based web-applications I feel like
it’s appropriate) applications into smaller, more manageable pieces.

The "Classical" Sinatra Application - Our Baseline
--------------------------------------------------

We’ll start with something paired down for simplicity’s sake. I’ll leave it as
an exercise to the reader to determine what this application does and instead
focus on code-style and organization.

```ruby

########
# app.rb
#

require 'sinatra'

set :root, File.dirname(__FILE__)

enable :sessions

def require_logged_in
  redirect('/sessions/new') unless is_authenticated?
end

def is_authenticated?
  return !!session[:user_id]
end

get '/' do
  erb :login
end

get '/sessions/new' do
  erb :login
end

post '/sessions' do
  session[:user_id] = params["user_id"]
  redirect('/secrets')
end

get '/secrets' do
  require_logged_in
  erb :secrets
end

```

Use Sinatra's "Modular" Style
-----------------------------

According to the [Sinatra docs][sinatra-extensions]: “When a classic style
application is run, all Sinatra::Application public class methods are exported
to the top-level." Also, using the classical style prevents you from running
more than
[one Sinatra application per Ruby process][sinatra-modular-vs-classic] - all
calls to these top-level methods are handled by Sinatra::Application,
functioning as a singleton. We can avoid these potentially-confusing scoping
problems by reorganizing our application into what Sinatra calls the "modular"
style, like so:

```ruby

########
# app.rb
#

require 'sinatra/base'

class SimpleApp < Sinatra::Base

  set :root, File.dirname(__FILE__)

  enable :sessions

  def require_logged_in
    redirect('/sessions/new') unless is_authenticated?
  end

  def is_authenticated?
    return !!session[:user_id]
  end

  get '/' do
    erb :login
  end

  get '/sessions/new' do
    erb :login
  end

  post '/sessions' do
    session[:user_id] = params["user_id"]
  end

  get '/secrets' do
    require_logged_in
    erb :secrets
  end

end

```

This app will need to be started with rackup via a config file (I called it
“config.ru”) that looks something like:

```ruby

###########
# config.ru
#

require File.dirname(__FILE__) + '/app'

run SimpleApp

```

Reduce Duplication via Lambdas
------------------------------

One thing you may find yourself wanting to do is bind multiple routes to the
same handler. While there’s nothing keeping you from factoring this shared code
into a method invoked in each route-handler’s block - it would be nice if we
had some clean, concise way to remove the duplicate blocks entirely. Using
lambdas passed as blocks, you can visually separate routes from their handlers
and share the handlers across routes with ease.

```ruby

########
# app.rb
#

require 'sinatra/base'

class SimpleApp < Sinatra::Base

  set :root, File.dirname(__FILE__)

  enable :sessions

  def require_logged_in
    redirect('/sessions/new') unless is_authenticated?
  end

  def is_authenticated?
    return !!session[:user_id]
  end

  show_login = lambda do
    erb :login
  end

  receive_login = lambda do
    session[:user_id] = params["user_id"]
    redirect '/secrets'
  end

  show_secrets = lambda do
    require_logged_in
    erb :secrets
  end

  get  '/', &show_login
  get  '/sessions/new', &show_login
  post '/sessions', &receive_login
  get  '/secrets', &show_secrets

end

```

Break Your Code Into Multiple Files
-----------------------------------

As your application grows larger (in line count) you’ll most likely want some
way of grouping together pieces of like-functionality into separate files which
are then required by your main Sinatra-application’s file. This can be achieved
using the “helpers” and “register” methods, like so:

```ruby

########
# app.rb
#

require 'sinatra/base'

require_relative 'helpers'
require_relative 'routes/secrets'
require_relative 'routes/sessions'

class SimpleApp < Sinatra::Base

  set :root, File.dirname(__FILE__)

  enable :sessions

  helpers Sinatra::SampleApp::Helpers

  register Sinatra::SampleApp::Routing::Sessions
  register Sinatra::SampleApp::Routing::Secrets

end


############
# helpers.rb
#

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


###################
# routes/secrets.rb
#

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


####################
# routes/sessions.rb
#

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

```

Takeaway
--------

These are just a few tips and tricks that you can use in your next
Sinatra-based project. We'll keep posting as we learn new ways to simplify and
organize our code - so stay tuned!

In the mean time, I encourage you to review the [Sinatra
documentation][sinatra-docs] and the excellent [Sinatra
Explained][sinatra-explained] project by Zheng Jia.

[sinatra-docs]: http://www.sinatrarb.com/documentation.html
[sinatra-explained]: https://github.com/zhengjia/sinatra-explained
[sinatra-extensions]: http://www.sinatrarb.com/extensions.html
[sinatra-modular-vs-classic]: http://www.sinatrarb.com/intro.html#Modular%20vs.%20Classic%20Style
