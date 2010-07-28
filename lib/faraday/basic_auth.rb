module Faraday
  class Request::BasicAuth < Faraday::Middleware
    def initialize(app, *args)
      @app      = app
      @user     = args.shift
      @password = args.shift
    end
    
    # basic auth code token from net/http source
    def call(env)
      env[:request_headers].merge!('Authorization' => 'Basic ' + ["#{@user}:#{@password}"].pack('m').delete("\r\n"))

      @app.call env
    end
  end
end
