require 'json'

module IndexTank
  class Function
    attr_reader :uri, :index, :formula

    def initialize(function_url, index, formula)
      @uri     = function_url
      @index   = index
      @formula = formula
    end

    def ==(other)
      self.uri == other.uri and
        self.index == other.index
        self.formula == other.formula
    end
  end
end
