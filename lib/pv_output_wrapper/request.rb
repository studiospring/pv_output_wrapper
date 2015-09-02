require "net/http"
require "addressable/template"
require "addressable/uri"

module PvOutputWrapper
  class Request
    BASE_URI = 'http://www.pvoutput.org/service'

    def initialize(api_key, system_id)
      @api_key = api_key
      @system_id = system_id
    end

    # @return [Net::HTTP]
    def request(uri)
      req = Net::HTTP::Get.new(uri)
      req['X-Pvoutput-Apikey'] = @api_key
      req['X-Pvoutput-SystemId'] = @system_id
      req
    end

    def service_path(service)
      "#{BASE_URI}/#{revision}/#{service}.jsp/{?query*}"
    end

    # @return [String] the api revision number.
    def revision(rev: 'r2')
      rev
    end

    # @params [String] service name, [Hash] query params.
    # @return [Addressable::Uri] pvoutput uri.
    def construct_uri(service, params={})
      template = Addressable::Template.new(service_path(service))
      template.expand({"query" => params})
    end

    # Make GET request to pvoutput api.
    # @return response (string).
    def get(service, params={})
      uri = construct_uri(service, params)
      req = request(uri)

      res = Net::HTTP.start(uri.host, 80) do |http|
        http.request(req).body
      end

      # begin
      #   response = req.read
      # rescue
      #   '' # fails silently
      # else
      #   case response.status[0][0]
      #   when '2', '3'
      #     response
      #   else
      #     '' # fails silently
      #   end
      # end
    end

    # @return [Hash<String, >] system data or nil values upon failure.
    def get_statistic(params={})
      get('getstatistic', params)

      # total_output is in watt hours
      # keys = ['total_output', 'efficiency', 'date_from', 'date_to']
      # results_array = response.split(/,/)
      # selected_results = results_array.values_at(0, 5, 7, 8)
      # Hash[keys.zip selected_results]
    end
  end
end
