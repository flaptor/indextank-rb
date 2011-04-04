require 'yajl/json_gem'

module IndexTank
  class Function
    attr_reader :uri, :index, :definition

    def initialize(function_url, index, definition)
      @uri        = "#{function_url}/#{index}"
      @index      = index
      @definition = definition
      @conn = IndexTank.setup_connection(@uri) do |faraday|
        # Function and Document have the same Response statuses
        faraday.use IndexTank::DocumentResponseMiddleware
      end
    end

    def add(options = {})
      raise MissingFunctionDefinition unless self.definition

      options.merge!(:definition => self.definition)
      response = @conn.put do |req|
        req.url ''
        req.body = options.to_json
      end

      true
    end

    def delete(options = {})
      resp = @conn.delete do |req|
        req.url ''
        req.body = options.to_json
      end

      true
    end

    def ==(other)
      self.uri == other.uri and
        self.index == other.index
        self.definition == other.definition
    end
  end
end
