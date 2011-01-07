require 'indextank/index'
require 'uri'

module IndexTank
  class Client
    attr_reader :uri

    def initialize(api_url)
      @uri = api_url
      builder = Proc.new { |builder| builder.use ClientResponseMiddleware }
      @conn = IndexTank.setup_connection(api_url, &builder)
    end

    def indexes(name = nil)
      if name.nil?
        list_indexes
      else
        get_index(name)
      end
    end

    private
    def list_indexes
      indexes = Hash.new

      @conn.get("/v1/indexes").body.each do |name, metadata|
        indexes[name] = Index.new("#{@uri}/v1/indexes/#{name}", metadata)
      end

      indexes
    end

    def get_index(name)
      Index.new("#{@uri}/v1/indexes/#{name}")
    end
  end

  class ClientResponseMiddleware < Faraday::Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |finished_env|
        case finished_env[:status]
        when 200
          nil # this is the expected return code
        when 204
          nil # this is the expected return code for empty responses
        when 401
          raise InvalidApiKey
        else
          raise UnexpectedHTTPException, finished_env[:body]
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
