require 'faraday'
require 'uri'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'indextank', 'client')

module IndexTank
  VERSION = "0.0.6"

  def self.setup_connection(url, &block)
    @conn = Faraday::Connection.new(:url => url) do |builder|
      builder.adapter Faraday.default_adapter
      builder.use Faraday::Response::Yajl
      if block_given? 
        block.call builder
      end 
    end
    @uri = URI.parse(url)
    @conn.basic_auth @uri.user,@uri.password
    @conn
  end
end

