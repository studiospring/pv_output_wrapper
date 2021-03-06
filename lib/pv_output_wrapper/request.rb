require "net/http"
require "addressable/template"
require "addressable/uri"

module PvOutputWrapper
  class Request
    # Do not use OpenURI, apparent security risk.
    # {http://sakurity.com/blog/2015/02/28/openuri.html}

    # @arg [String]
    def initialize(api_key, system_id)
      @headers = {
        'X-Pvoutput-Apikey' => api_key,
        'X-Pvoutput-SystemId' => system_id
      }
    end

    private

    # @arg [Symbol, Hash{<Symbol, String> => String}]
    def method_missing(service, *args, &block)
      if PvOutputWrapper::VALID_SERVICES.include?(service)
        params = symbolise_params(args.fetch(0, {}))
        get_response(service, params)
      else
        super
      end
    end

    # TODO: raise and log response errors
    # @arg [Symbol, Hash{<Symbol, String> => String}]
    # @return [PvOutput::Response]
    def get_response(service, args)
      uri = construct_uri(service, args)
      PvOutputWrapper::Response.new(uri, get_request(uri))
    end

    # @arg [String, URI] full uri including any params.
    # #return [Net::HTTP]
    def get_request(uri)
      retries = 2

      begin
        connection = Net::HTTP.new(PvOutputWrapper::HOST, 80)
        connection.get(uri, @headers)
      rescue SocketError => e
        raise "Net::HTTP SocketError: #{e.message}, requested uri: #{uri}, headers: #{@headers}"
      # rescue IOERROR => ioe
      #   raise ioe.message
      rescue StandardError, Timeout::Error # => e
        # PvOutputWrapper::Logger.logger.error(e)
        sleep 2
        retry if (retries -= 1) > 0
        connection.finish
        raise
      end
    end

    # @arg [Symbol] service name, [Hash{Symbol => String}] query params.
    # @return [Addressable::URI] pvoutput uri.
    def construct_uri(service, params={})
      if invalid_params?(service, params)
        raise ArgumentError,
              "Invalid params: #{params.keys.inspect} passed to #{service} request."
      end

      service_name = service.to_s.delete "_"
      template = Addressable::Template.new(service_path(service_name))
      template.expand({"query" => valid_params(service, params)})
    end

    # @arg [Symbol, Hash<Symbol, String>]
    # @return [True, False]
    def invalid_params?(service, params)
      invalid_param_keys = params.keys - PvOutputWrapper::VALID_SERVICES[service]
      invalid_param_keys.any?
    end

    # @arg [Hash{<Symbol,String> => String] query params.
    # @return [Hash{<Symbol> => String] allows strings to be passed as param keys.
    def symbolise_params(params)
      params.reduce({}) { |a, (k, v)| a.merge(k.to_sym => v) }
    end

    # NOTE: this does not handle required params (bc there are none at present)
    # @return [Hash] may be an empty hash if no params are required.
    def valid_params(service, params)
      params.keep_if { |k, _| PvOutputWrapper::VALID_SERVICES[service].include?(k) }
    end

    # "http://" must be added here, not to HOST bc Net::HTTP.new takes only the host.
    # @arg [String] service path as defined by pvoutput.org.
    def service_path(service)
      uri_string = "http://#{PvOutputWrapper::HOST}/service/#{revision}/#{service}.jsp{?query*}"
      Addressable::URI.parse(uri_string)
    end

    # @return [String] the api revision number.
    def revision(rev: 'r2')
      rev
    end
  end
end
