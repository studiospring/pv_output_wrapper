require "net/http"
require "addressable/template"
require "addressable/uri"

module PvOutputWrapper
  class Request
    # Do not use OpenURI, apparent security risk.
    # Method names must be the same as corresponding pvoutput.org api path name,
    #   with optional underscores.

    # Include the scheme to prevent Addressable bug.
    # See {https://github.com/bblimke/webmock/issues/489a}
    HOST = 'http://www.pvoutput.org'

    def initialize(api_key, system_id)
      @headers = {
        'X-Pvoutput-Apikey' => api_key,
        'X-Pvoutput-Systemid' => system_id
      }
    end

    # @return [PvOutput::Response]
    def get_statistic(df: nil, dt: nil, c: nil, crdr: nil, sid: nil)
      params = binding.local_variables.map { |p| [p, binding.local_variable_get(p.to_s)] }.to_h
      params.delete_if { |_, v| v.nil? }
      method_name = __method__.to_s
      uri = construct_uri(method_name, params)
      PvOutputWrapper::Response.new(method_name, get_response(uri))
    end

    private

      # @param [String, URI] full uri including any params.
      def get_response(uri)
        connection = Net::HTTP.new(HOST, 80)
        connection.get(uri, @headers)
      end

      # @params [String] service name, [Hash] query params.
      # @return [Addressable::URI] pvoutput uri.
      def construct_uri(service, params={})
        service_name = service.delete "_"
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
