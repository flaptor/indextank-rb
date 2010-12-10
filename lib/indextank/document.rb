require 'json'
require 'faraday'

module IndexTank
  class Document
    attr_reader :docid

    def initialize(document_url, docid)
      @docid = docid
      @conn  = IndexTank.setup_connection(document_url) proc { |builder| builder.use Indextank::ResponseDocument }
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

    # updates the categories of a given document
    # the categories argument should be a Hash from string
    # to string defining the value for each category defined
    # by this document.
    def update_categories(categories, options = {} )
      options.merge!(:docid => self.docid, :categories => categories)
      resp = @conn.put do |req|
        req.url "categories"
        req.body = options.to_json
      end

      resp.status == 200
    end

  end

  class ResponseDocument < Faraday::Response::Middleware
    def self.register_on_complete(env)
      env[:response].on_complete do |finished_env|
        case finished_env[:status]
        when 200
          raise Bleh
        when 400
          raise InvalidArgument
        when 409
          raise IndexInitializing
        when 404
          raise IndexNotFound
        end
      end
    end

    def initialize(app)
      super
      @parser = nil
    end
  end
end
