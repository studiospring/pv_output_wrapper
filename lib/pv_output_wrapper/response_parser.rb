module Pvoutput
  class ResponseParser
    def initialize(service, body)
      @service = service
      @body = body
    end

    def parse
      case @service
      when 'getstatistic'
        get_statistic
      else
        @body
      end
    end

    private

      # @return [Hash<String, >] system data or nil values upon failure.
      def get_statistic
        # total_output is in watt hours
        keys = ['total_output', 'efficiency', 'date_from', 'date_to']
        results_array = @body.split(/,/)
        selected_results = results_array.values_at(0, 5, 7, 8)
        Hash[keys.zip selected_results]
      end
  end
end
