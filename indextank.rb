require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

BASE_URL = 'http://api.indextank.com/api/v0'
class IndexTank
    def initialize(api_key, options={})
        @api_key = api_key
        @def_index_code = options[:index_code]
        @def_index_name = options[:index_name]
    end

    def create_index(index_name)
        return api_call("admin/create", "index_code", :index_name => index_name)
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def delete_index(options={})
        return api_call("admin/delete", nil, options)
    end


    def list_indexes()
        return api_call("admin/list", "results")
    end


    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def add(doc_id, content, options={})
        options.merge!(:document_id => doc_id, :document => content.to_json)
        options[:boosts] = options[:boosts].to_json if options.key?(:boosts)             
        return api_call("index/add", nil, options)
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def update_boosts(doc_id, boosts, options={})
        options.merge!(:document_id => doc_id, :boosts => boosts.to_json)
        return api_call("index/update_boosts", nil, options)
    end


    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def promote(doc_id, query, options={})
        options.merge!(:document_id => doc_id, :query => query)
        return api_call("index/promote", nil, options)
    end


    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def delete(doc_id, options={})
        options.merge!(:document_id => doc_id)
        return api_call("index/delete", nil, options)
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code
    # it can also contain any of the following:
    #   :start => an int with the number of results to skip
    #   :len => an int with the number of results to return
    #   :snippet_fields => a comma separated list of field names for which a snippet
    #                      should be returned. (requires an index that supports snippets)
    #   :fetch_fields => a comma separated list of field names for which its content
    #                    should be returned. (requires an index that supports storage)
    #   :relevance_function => an int with the index of the relevance function to be used
    #                          for this query 
    def search(query, options={})
        options = { :start => 0, :len => 10 }.merge(options)
        options.merge!(:query => query)
        return api_call("search/query", "results", options)
    end

    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def add_function(function_index, definition, options={})
        options.merge!( :function_id => function_index, :definition => definition )
        return api_call("index/add_function", nil, options)
    end
    
    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def del_function(function_index, options={})
        options.merge!( :function_id => function_index )
        return api_call("index/remove_function", nil, options)
    end
    
    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def list_functions(options={})
        return api_call("index/list_functions", "results", options)
    end

       
    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def index_stats(options={})
        return api_call("index/stats", "results", options)
    end


    # the options argument may contain an :index_code definition to override 
    # this instance's default index_code  
    def search_stats(options={})
        return api_call("search/stats", "results", options)
    end

    private

    def base_url
        return ENV['INDEXTANK_BASE_URL'] || BASE_URL
    end

    def api_call(method, return_key, params={})
        params = { "api_key" => @api_key }.merge(params)
        params = { :index_code => @def_index_code }.merge(params) unless @def_index_code.nil?
        params = { :index_name => @def_index_name }.merge(params) unless @def_index_name.nil?
        url = base_url + '/' + method
        req = Net::HTTP::Post.new(url)
        req.set_form_data(params, ';')
        res = Net::HTTP.new(URI.parse(base_url).host).start {|http| http.request(req) }
        if res.is_a? Net::HTTPOK
            result = JSON.parse(res.body)
            ok = result['status'] == 'OK'
            return ok ? [ok, (return_key.nil? ? nil : result[return_key])] : [ok, result['message']]
        elsif res.is_a? Net::HTTPForbidden
            return false, "Access forbidden"
        elsif res.is_a? Net::HTTPClientError
            return false, "Unknown client error"
        elsif res.is_a? Net::HTTPServerError
            puts res.body
            return false, "Unknown server error"
        else
            puts res.body
            return false, "Unexpected response"
        end
    end

end
