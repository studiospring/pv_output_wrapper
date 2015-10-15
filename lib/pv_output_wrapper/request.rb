require "net/http"
require "addressable/template"
require "addressable/uri"

module PvOutputWrapper
  class Request
    # Do not use OpenURI, apparent security risk.
    # {http://sakurity.com/blog/2015/02/28/openuri.html}

    # @arg [String]
    def initialize(api_key, system_id)
      @api_key = api_key
      @system_id = system_id
      # @headers = {
      #   'X-Pvoutput-Apikey' => api_key,
      #   'X-Pvoutput-SystemId' => system_id
      # }
    end

    # private

    # @arg [Symbol, Hash<Symbol, String>]
    def method_missing(service, *args, &block)
      if PvOutputWrapper::VALID_SERVICES.include?(service)
        params = args.fetch(0, {})
        get_response(service, params)
      else
        super
      end
    end

    # TODO: raise and log response errors
    # @arg [Symbol, Hash<Symbol, String>]
    # @return [PvOutput::Response]
    def get_response(service, args)
      uri = construct_uri(service, args)
      PvOutputWrapper::Response.new(service, get_request(uri))
    end

    # @arg [String, URI] full uri including any params.
    def get_request(uri)
      retries = 2

      begin
        connection = Net::HTTP.new(PvOutputWrapper::HOST, 80)
        connection.get(uri)
      rescue SocketError
        raise "SocketError: connection: #{connection.inspect}"
        # raise "SocketError: requested uri: #{uri}, headers: #{@headers}"
      rescue IOERROR => ioe
        raise ioe.message
      rescue StandardError, Timeout::Error # => e
        # PvOutputWrapper::Logger.logger.error(e)
        sleep 2
        retry if (retries -= 1) > 0
        connection.finish
        raise
      end
    end

    # @arg [Symbol] service name, [Hash] query params.
    # @return [Addressable::URI] pvoutput uri.
    def construct_uri(service, params={})
      if invalid_params?(service, params)
        raise ArgumentError,
              "Invalid params: #{params.keys.inspect} passed to #{service} request."
      end

      service_name = service.to_s.delete "_"
      template = Addressable::Template.new(service_path(service_name))
      params = {"query" => valid_params(service, params)}
      params["key"] = @api_key
      params["sid"] = @system_id
      template.expand(params)
    end

    # @return [True, False]
    def invalid_params?(service, params)
      invalid_param_keys = params.keys - PvOutputWrapper::VALID_SERVICES[service]
      invalid_param_keys.any?
    end

    # NOTE: this does not handle required params (bc there are none at present)
    # @return [Hash] may be an empty hash if no params are required.
    def valid_params(service, params)
      params.keep_if { |k, _| PvOutputWrapper::VALID_SERVICES[service].include?(k) }
    end

    # @arg [String] service path as defined by pvoutput.org.
    def service_path(service)
      uri_string = "#{PvOutputWrapper::HOST}/service/#{revision}/#{service}.jsp/{?query*}"
      Addressable::URI.parse(uri_string)
    end

    # @return [String] the api revision number.
    def revision(rev: 'r2')
      rev
    end
  end
end
