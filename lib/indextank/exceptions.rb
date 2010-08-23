module IndexTank
  class IndexAlreadyExists < StandardError; end
  class TooManyIndexes < StandardError; end
  class MissingFunctionDefinition < StandardError; end
end
