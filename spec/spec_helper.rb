$:.unshift File.expand_path("../../lib", __FILE__)

require 'rspec/core'
require 'rspec/expectations'
require 'rr'

require 'indextank'

def not_in_editor?
  !(ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM'))
end

RSpec.configure do |c|
  c.run_all_when_everything_filtered = true
  c.filter_run :focused => true
  c.alias_example_to :fit, :focused => true
  c.color_enabled = not_in_editor?
  c.mock_with :rr
end

def stub_setup_connection
  stub(IndexTank).setup_connection(anything) do |url|
    Faraday::Connection.new(:url => url) do |builder|
      builder.use FaradayStack::ResponseJSON
      yield builder if block_given?
      builder.adapter :test, stubs
    end
  end
end
