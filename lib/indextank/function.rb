require 'json'

module IndexTank
  class Function
    attr_reader :uri, :index, :definition

    def initialize(function_url, index, definition)
      @uri     = "#{function_url}/#{index}"
      @index   = index
      @definition = definition
      @conn    = IndexTank.setup_connection(@uri)
    end

    def ==(other)
      self.uri == other.uri and
        self.index == other.index
        self.definition == other.definition
    end
  end
end
