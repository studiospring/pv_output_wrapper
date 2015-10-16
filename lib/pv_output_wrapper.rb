require "pv_output_wrapper/version"
require "pv_output_wrapper/request"
require "pv_output_wrapper/response"

module PvOutputWrapper
  # Include the scheme to prevent Addressable bug.
  # See {https://github.com/bblimke/webmock/issues/489a}
  # NO! DON'T! Or else you get a SocketError.
  HOST = 'pvoutput.org'

  # Service names must be the same as corresponding pvoutput.org api path name,
  #   with optional underscores.
  VALID_SERVICES = {
    :get_statistic => [:df, :dt, :c, :crdr, :sid1],
    :get_status => [:d, :t, :h, :asc, :limit, :from, :to, :ext, :sid1],
    :get_system => [:array2, :tariffs, :teams, :est, :donations, :sid1, :ext],
    :search => ['q', :ll, :country],
  }

  class Logger
    attr_accessor :logger
  end
end
