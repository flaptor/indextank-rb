require 'json'

module IndexTank
  class Function
    attr_reader :uri, :index, :definition

    def initialize(function_url, index, definition)
      @uri        = "#{function_url}/#{index}"
      @index      = index
      @definition = definition
      @conn       = IndexTank.setup_connection(@uri)
    end

    def add(options = {})
      raise MissingFunctionDefinition unless self.definition

      options.merge!(:definition => self.definition)
      resp = @conn.put do |req|
        req.url ''
        req.body = options.to_json
      end

      resp.status == 200
    end

    def delete(options = {})
      resp = @conn.delete do |req|
        req.url ''
        req.body = options.to_json
      end

      resp.status == 200
    end

    def ==(other)
      self.uri == other.uri and
        self.index == other.index
        self.definition == other.definition
    end
  end
end
