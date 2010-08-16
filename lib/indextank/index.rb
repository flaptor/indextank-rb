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

    def refresh
      response = @conn.get('')
      if response.status == 200
        @metadata = response.body
      end

      response
    end

    def delete
      response = @conn.delete('')
    end

    def running?
      refresh
      @metadata['started']
    end

    def method_missing(sym, *args, &block)
      refresh if @metadata.nil?
      @metadata[sym.to_s]
    end

    def exists?
      refresh.status != 404
    end
  end
end
