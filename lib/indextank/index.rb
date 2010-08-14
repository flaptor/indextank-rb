require 'indextank/exceptions'
require 'json'

module IndexTank
  class IndexHash < Hash
  end

  class Index
    def initialize(index_url, metadata = nil)
      @conn = IndexTank.setup_connection(index_url)

      @metadata = metadata
    end

    def add
      response = @conn.put('')
      case response.status
      when 201
        true
      when 204
        raise IndexAlreadyExists
      when 409
        raise TooManyIndexes
      end
    end

    def delete
      response = @conn.delete('')
    end

    def method_missing(sym, *args, &block)
      @metadata[sym.to_s]
    end
  end
end
