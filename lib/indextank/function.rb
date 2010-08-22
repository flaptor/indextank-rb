require 'json'

module IndexTank
  class Function
    attr_reader :uri, :index, :definition

      @uri     = function_url
    def initialize(function_url, index, definition)
      @index   = index
      @definition = definition
    end

    def ==(other)
      self.uri == other.uri and
        self.index == other.index
        self.definition == other.definition
    end
  end
end
