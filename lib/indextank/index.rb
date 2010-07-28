module IndexTank
  class IndexHash < Hash
  end

  class Index
    def initialize(index_url, metadata = nil)
      @conn = IndexTank.setup_connection(index_url)

      @metadata = metadata
    end
  end
end
