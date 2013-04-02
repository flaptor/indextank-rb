require 'faraday_middleware'
require 'uri'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'indextank', 'client')

module IndexTank
  VERSION = "1.0.12"

  def self.setup_connection(url)
    @conn = Faraday::Connection.new(:url => url) do |builder|
      builder.use FaradayMiddleware::ParseJson
      yield builder if block_given?
      builder.adapter Faraday.default_adapter
    end
    @uri = URI.parse(url)
    @conn.basic_auth @uri.user,@uri.password
    @conn.headers['User-Agent'] = "IndexTank-Ruby/#{VERSION}"
    @conn
  end
end

