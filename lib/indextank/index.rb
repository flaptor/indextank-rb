require 'indextank/exceptions'
require 'indextank/document'
require 'indextank/function'
require 'yajl/json_gem'

module IndexTank
  class Index
    def initialize(index_url, metadata = nil)
      @uri      = index_url
      @conn     = IndexTank.setup_connection(index_url)
      @metadata = metadata
    end

    def add( options = {} )
      options = {:public_search => false}.merge(options)
      
      response = @conn.put do |req|
        req.url ""
        req.body = options.to_json
      end
      case response.status
      when 201
        true
      when 204
        raise IndexAlreadyExists
      when 409
        raise TooManyIndexes
      when 401 
        raise InvalidApiKey 
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
      case response.status
      when 204
        raise NonExistentIndex
      end
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

    def batch_insert(documents)
      resp = @conn.put do |req|
        req.url "docs"
        req.body = documents.to_json
      end
      case resp.status
      when 200
        resp.body
      when 401
        raise InvalidApiKey
      when 409
        raise IndexInitializing
      when 404
        raise NonExistentIndex
      when 400
        raise InvalidArgument, resp.body
      else
        raise UnexpectedHTTPException, resp.body
      end
    end

    def bulk_delete(docids)
      data = []
      docids.each do |docid|
        data << {'docid' => docid}
      end
      resp = @conn.delete do |req|
        req.url "docs"
        req.body = data.to_json
      end
      case resp.status
      when 200
        resp.body
      when 401
        raise InvalidApiKey
      when 409
        raise IndexInitializing
      when 404
        raise NonExistentIndex
      when 400
        raise InvalidArgument, resp.body
      else
        raise UnexpectedHTTPException, resp.body
      end
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code
    # it can also contain any of the following:
    #   :start => an int with the number of results to skip
    #   :len => an int with the number of results to return
    #   :snippet => a comma separated list of field names for which a snippet
    #               should be returned. (requires an index that supports snippets)
    #   :fetch => a comma separated list of field names for which its content
    #             should be returned. (requires an index that supports storage)
    #   :function => an int with the index of the scoring function to be used
    #                for this query
    #   :variables => a hash int => float, with variables that can be later
    #                 used in scoring :function
    #   :category_filters => a hash to filter the query based on document categories. Keys represent category names.
    #                       see http://indextank.com/documentation/ruby-client#faceting
    #
    #                       Example:
    #                         category_filters => {:size => "big", :price => "expensive"}
    #                         means that only documents that have "big" as size category and "expensive" as price category
    #                         will match the query
    #   :docvar_filters =>  a hash with int keys and Array values to filter the query based on document variables.
    #                       see http://indextank.com/documentation/ruby-client#range_queries
    #
    #                       Example: 
    #                           docvar_filters = { 1 => [ [2, 3], [5, nil] ]} 
    #                           means that only documents with document variable number 1 between 2 and 3 or bigger than 5
    #                           will match the query.
    #   :function_filters => a hash with int keys and Array values to filter the query based on scoring functions.
    #                       see http://indextank.com/documentation/ruby-client#range_queries
    #
    #                       Example: 
    #                           function_filters = { 3 => [ [nil, 2], [5, 7], [8,14] ]} 
    #                           means that only documents whose score calculated by scoring function 3 is lower than 2,
    #                           between 5 and 7 or between 8 and 14 will match the query.
    def search(query, options = {})
      options = {:start => 0, :len => 10 }.merge(options).merge(:q => query)
      if options[:variables]
        options[:variables].each_pair { |k, v| options.merge!( :"var#{k}" => v ) }
        options.delete :variables
      end

      if options[:docvar_filters]
        # go from { 3 => [ [1, 3], [5, nil] ]} to filter_docvar3 => 1:3,5:*
        options[:docvar_filters].each_pair { |k, v| 
                                              rng = v.map { |val|
                                                raise ArgumentError, "using a range with bound count != 2"  unless val.length == 2
                                                "#{val[0] || '*'}:#{val[1] || '*'}"
                                              }.join ","
                                              options.merge!( :"filter_docvar#{k}" => rng ) 
                                           }
        options.delete :docvar_filters
      end

      if options[:function_filters]
        # go from { 2 => [ [1 , 3],[5,8] ]} to filter_function2 => 1:3,5:8
        options[:function_filters].each_pair { |k, v| 
                                              rng = v.map { |val|
                                                raise ArgumentError, "using a range with bound count != 2"  unless val.length == 2
                                                "#{val[0] || '*'}:#{val[1] || '*'}"
                                              }.join ","
                                              options.merge!( :"filter_function#{k}" => rng ) 
                                           }
        options.delete :function_filters
      end

      if options[:category_filters]
        options[:category_filters] = options[:category_filters].to_json
      end

      response = @conn.get do |req|
        req.url 'search', options
      end  
      case response.status
      when 400
        raise InvalidQuery
      when 404
        raise NonExistentIndex
      when 409
        raise IndexInitializing
      end

      response.body
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code
    # it can also contain any of the following:
    #   :start => an int with the number of results to skip
    #   :function => an int with the index of the scoring function to be used
    #                for this query
    #   :variables => a hash int => float, with variables that can be later
    #                 used in scoring :function
    #   :category_filters => a hash to filter the query based on document categories. Keys represent category names.
    #                       see http://indextank.com/documentation/ruby-client#faceting
    #
    #                       Example:
    #                         category_filters => {:size => "big", :price => "expensive"}
    #                         means that only documents that have "big" as size category and "expensive" as price category
    #                         will match the query
    #   :docvar_filters =>  a hash with int keys and Array values to filter the query based on document variables.
    #                       see http://indextank.com/documentation/ruby-client#range_queries
    #
    #                       Example: 
    #                           docvar_filters = { 1 => [ [2, 3], [5, nil] ]} 
    #                           means that only documents with document variable number 1 between 2 and 3 or bigger than 5
    #                           will match the query.
    #   :function_filters => a hash with int keys and Array values to filter the query based on scoring functions.
    #                       see http://indextank.com/documentation/ruby-client#range_queries
    #
    #                       Example: 
    #                           function_filters = { 3 => [ [nil, 2], [5, 7], [8,14] ]} 
    #                           means that only documents whose score calculated by scoring function 3 is lower than 2,
    #                           between 5 and 7 or between 8 and 14 will match the query.
    def delete_by_search(query, options = {})
      options = {:start => 0}.merge(options).merge(:q => query)
      if options[:variables]
        options[:variables].each_pair { |k, v| options.merge!( :"var#{k}" => v ) }
        options.delete :variables
      end

      if options[:docvar_filters]
        # go from { 3 => [ [1, 3], [5, nil] ]} to filter_docvar3 => 1:3,5:*
        options[:docvar_filters].each_pair { |k, v| 
                                              rng = v.map { |val|
                                                raise ArgumentError, "using a range with bound count != 2"  unless val.length == 2
                                                "#{val[0] || '*'}:#{val[1] || '*'}"
                                              }.join ","
                                              options.merge!( :"filter_docvar#{k}" => rng ) 
                                           }
        options.delete :docvar_filters
      end

      if options[:function_filters]
        # go from { 2 => [ [1 , 3],[5,8] ]} to filter_function2 => 1:3,5:8
        options[:function_filters].each_pair { |k, v| 
                                              rng = v.map { |val|
                                                raise ArgumentError, "using a range with bound count != 2"  unless val.length == 2
                                                "#{val[0] || '*'}:#{val[1] || '*'}"
                                              }.join ","
                                              options.merge!( :"filter_function#{k}" => rng ) 
                                           }
        options.delete :function_filters
      end

      if options[:category_filters]
        options[:category_filters] = options[:category_filters].to_json
      end

      response = @conn.delete do |req|
        req.url 'search', options
      end  
      case response.status
      when 400
        raise InvalidQuery
      when 404
        raise NonExistentIndex
      when 409
        raise IndexInitializing
      end

      response.body
    end

    def suggest(query, options = {})
      options.merge!({:query => query})
      @conn.get do |req|
        req.url 'autocomplete', options
      end.body
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def promote(docid, query, options={})
      options.merge!( :docid => docid, :query => query )
      resp = @conn.put do |req|
        req.url 'promote'
        req.body = options.to_json
      end
      
      case resp.status
      when 409
        raise IndexInitializing
      when 404
        raise NonExistentIndex
      when 400
        raise InvalidArgument, resp.body
      end
    end

    # creates a new document, identified by :docid
    # :docid => a String or Symbol, with bytesize no longer than 1024 bytes
    def document(docid)
      Document.new("#{@uri}/docs", docid)
    end

    def functions(index = -1, formula = nil)
      if index == -1
        @conn.get("functions").body.sort.collect do |index, formula|
          Function.new("#{@uri}/functions", index, formula)
        end
      else
        Function.new("#{@uri}/functions", index, formula)
      end
    end
  end
end
