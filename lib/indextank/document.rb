require 'json'

module IndexTank
  class Document
    attr_reader :docid

    def initialize(document_url, docid)
      @docid = docid
      @conn  = IndexTank.setup_connection(document_url)
    end

    # the options argument may contain a :variables key
    # with a Hash from variable numbers to their float values
    # this variables can be used in the scoring functions
    # when sorting a search
    def add(fields, options = {})
      options.merge!(:docid => self.docid, :fields => fields)
      resp = @conn.put do |req|
        req.url ""
        req.body = options.to_json
      end

      resp.status == 200
    end

    def delete(options = {})
      options.merge!(:docid => self.docid)
      resp = @conn.delete do |req|
        req.url ""
        req.body = options.to_json
      end

      resp.status == 200
    end

    def update_variables(variables, options = {})
      options.merge!(:docid => self.docid, :variables => variables)
      resp = @conn.put do |req|
        req.url "variables"
        req.body = options.to_json
      end

      resp.status == 200
    end
  end
end
