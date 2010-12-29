require 'json'

module IndexTank
  class Function
    attr_reader :uri, :index, :definition

    def initialize(function_url, index, definition)
      @uri        = "#{function_url}/#{index}"
      @index      = index
      @definition = definition
      builder = Proc.new { |builder| builder.use ResponseDocument }
      @conn  = IndexTank.setup_connection(@uri, &builder)
    end

    def add(options = {})
      raise MissingFunctionDefinition unless self.definition

      options.merge!(:definition => self.definition)
      response = @conn.put do |req|
        req.url ''
        req.body = options.to_json
      end
    end

    def delete(options = {})
      resp = @conn.delete do |req|
        req.url ''
        req.body = options.to_json
      end
    end

    def ==(other)
      self.uri == other.uri and
        self.index == other.index
        self.definition == other.definition
    end
  end
  class ResponseDocument < Faraday::Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |finished_env|
        case finished_env[:status]
        when 401
          raise InvalidApiKey
        when 409
          raise IndexInitializing
        when 404
          raise NonExistentIndex
        when 400
          raise InvalidArgument
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
