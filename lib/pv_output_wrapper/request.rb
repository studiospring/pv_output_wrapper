require "net/http"
require "addressable/template"
require "addressable/uri"

module PvOutputWrapper
  class Request
    # Do not use OpenURI, apparent security risk.

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
    def get_statistic(params={})
      uri = construct_uri('getstatistic', params)
      get_response(uri).body

      # total_output is in watt hours
      # keys = ['total_output', 'efficiency', 'date_from', 'date_to']
      # results_array = response.split(/,/)
      # selected_results = results_array.values_at(0, 5, 7, 8)
      # Hash[keys.zip selected_results]
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
        template = Addressable::Template.new(service_path(service))
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
