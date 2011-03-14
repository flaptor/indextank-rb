require 'faraday'
require 'uri'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'indextank', 'client')

module IndexTank
  VERSION = "1.0.8.2"

  def self.setup_connection(url, &block)
    @conn = Faraday::Connection.new(:url => url, :ssl => {:verify => false} ) do |builder|
      builder.adapter Faraday.default_adapter
      builder.use Faraday::Response::Yajl
      if block_given? 
        block.call builder
      end 
    end
    @uri = URI.parse(url)
    @conn.basic_auth @uri.user,@uri.password
    @conn.headers['User-Agent'] = "IndexTank-Ruby/#{VERSION}"
    @conn
  end
end

