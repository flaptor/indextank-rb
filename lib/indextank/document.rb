require 'json'

module IndexTank
  class Document
    attr_reader :docid

    def initialize(document_url, docid)
      @docid = docid
      @conn  = IndexTank.setup_connection(document_url)
    end

    def add(fields, options = {})
      options.merge!(:docid => self.docid, :fields => fields)
      resp = @conn.put do |req|
        req.url ""
        req.body = options.to_json
      end

      if resp.status == 200
        true
      else
        false
      end
    end

    def delete(options = {})
      options.merge!(:docid => self.docid)
      resp = @conn.delete do |req|
        req.url ""
        req.body = options.to_json
      end

      resp.status == 200
    end
  end
end
