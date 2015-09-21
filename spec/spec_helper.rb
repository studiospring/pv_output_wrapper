$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pv_output_wrapper'
require 'pv_output_wrapper/request'
require 'pv_output_wrapper/response'
require 'webmock/rspec'
require 'support/utilities'

WebMock.disable_net_connect!(:allow_localhost => true)

RSpec.configure do |_config|
  # config.filter_gems_from_backtrace "ignored_gem", "another_ignored_gem"
end
