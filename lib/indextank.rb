require 'faraday'
require 'faraday_middleware'

require 'indextank/client'
require 'faraday/basic_auth'

module IndexTank
  def self.setup_connection(url)
    uri = URI.parse(url)
    Faraday::Connection.new(:url => url) do |builder|
      builder.use Faraday::Request::BasicAuth, uri.user, uri.password
      builder.adapter Faraday.default_adapter
      builder.use Faraday::Response::MultiJson
      builder.use Faraday::Response::Mashify
    end
  end
end
