require 'indextank/index'
require 'uri'

module IndexTank
  class Client
    attr_reader :uri

    def initialize(api_url)
      @uri = api_url
      @conn = IndexTank.setup_connection(api_url)
    end

    def indexes(name = nil)
      if name.nil?
        list_indexes
      else
        get_index(name)
      end
    end

    private
    def list_indexes
      indexes = Hash.new

      @conn.get("/v1/indexes").body.each do |name, metadata|
        indexes[name] = Index.new("#{@uri}/v1/indexes/#{name}", metadata)
      end

      indexes
    end

    def get_index(name)
      Index.new("#{@uri}/v1/indexes/#{name}")
    end
  end
end
