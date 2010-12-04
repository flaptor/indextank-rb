require 'faraday'

directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'indextank', 'client')

module IndexTank
  VERSION = "0.0.1"

  def self.setup_connection(url)
    Faraday::Connection.new(:url => url) do |builder|
      builder.adapter Faraday.default_adapter
      builder.use Faraday::Response::Yajl
    end
  end
end
