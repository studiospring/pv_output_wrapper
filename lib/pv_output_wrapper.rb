require "pv_output_wrapper/version"

module PvOutputWrapper
  # Include the scheme to prevent Addressable bug.
  # See {https://github.com/bblimke/webmock/issues/489a}
  HOST = 'http://www.pvoutput.org'

  # Service names must be the same as corresponding pvoutput.org api path name,
  #   with optional underscores.
  VALID_SERVICES = {:get_statistic => [:df, :dt, :c, :crdr, :sid],
                    :get_status => [:d, :t, :h, :asc, :limit, :from, :to, :ext, :sid1]}

  class Logger
    attr_accessor :logger
  end
end
