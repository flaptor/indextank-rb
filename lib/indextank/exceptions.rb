module IndexTank
  class IndexAlreadyExists < StandardError; end
  class NonExistentIndex < StandardError; end
  class TooManyIndexes < StandardError; end
  class MissingFunctionDefinition < StandardError; end
  class InvalidApiKey < StandardError; end
  class InvalidQuery < StandardError; end
  class IndexInitializing < StandardError; end
  class InvalidArgument < StandardError; end
end
