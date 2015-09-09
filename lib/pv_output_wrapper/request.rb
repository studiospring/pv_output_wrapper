require "net/http"
require "addressable/template"
require "addressable/uri"

module PvOutputWrapper
  class Request
    # Do not use OpenURI, apparent security risk.
    # {http://sakurity.com/blog/2015/02/28/openuri.html}

    # Include the scheme to prevent Addressable bug.
    # See {https://github.com/bblimke/webmock/issues/489a}
    HOST = 'http://www.pvoutput.org'

    # Service names must be the same as corresponding pvoutput.org api path name,
    #   with optional underscores.
    VALID_SERVICES = [:get_statistic, :get_status]

    def initialize(api_key, system_id)
      @headers = {
        'X-Pvoutput-Apikey' => api_key,
        'X-Pvoutput-Systemid' => system_id
      }
    end

    # TODO: raise and log response errors
    # @return [PvOutput::Response]
    # def get_statistic(df: nil, dt: nil, c: nil, crdr: nil, sid: nil)
    #   params = binding.local_variables.map { |p| [p, binding.local_variable_get(p.to_s)] }.to_h
    #   params.delete_if { |_, v| v.nil? }
    #   method_name = __method__.to_s
    #   uri = construct_uri(method_name, params)
    #   PvOutputWrapper::Response.new(method_name, get_request(uri))
    # end

    private

    # TODO: validate args for each service.
    # @param [Symbol, Hash<Symbol, String>]
    def method_missing(service, **args)
      get_response(service, args) if VALID_SERVICES.include?(service)
    end

    # TODO: raise and log response errors
    # @param [Symbol, Hash<Symbol, String>]
    # @return [PvOutput::Response]
    def get_response(service, args)
      uri = construct_uri(service, args)
      PvOutputWrapper::Response.new(service, get_request(uri))
    end

    # @param [String, URI] full uri including any params.
    def get_request(uri)
      retries = 2

      begin
        connection = Net::HTTP.new(HOST, 80)
        connection.get(uri, @headers)
      rescue StandardError, Timeout::Error => e
        PvOutputWrapper::Logger.logger.error(e)
        sleep 2
        retry if (retries -= 1) > 0
        connection.finish
        raise
      end
    end

    # @params [Symbol] service name, [Hash] query params.
    # @return [Addressable::URI] pvoutput uri.
    def construct_uri(service, params={})
      service_name = service.to_s.delete "_"
      template = Addressable::Template.new(service_path(service_name))
      template.expand({"query" => params})
    end

    # @param [String] service path as defined by pvoutput.org.
    def service_path(service)
      uri_string = "#{HOST}/service/#{revision}/#{service}.jsp/{?query*}"
      Addressable::URI.parse(uri_string)
    end

    # @return [String] the api revision number.
    def revision(rev: 'r2')
      rev
    end
  end
end
