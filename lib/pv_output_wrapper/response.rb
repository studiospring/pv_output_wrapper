module PvOutputWrapper
  class Response
    attr_reader :response

    def initialize(service, response)
      @service = service
      @response = response
    end

    def body
      @response.body
    end


    # TODO: raise exception
    def parse
      method(@service).call
    end

    private

      # @return [Hash<String, >] system data or nil values upon failure.
      def get_statistic
        # total_output is in watt hours
        keys = ['total_output', 'efficiency', 'date_from', 'date_to']
        results_array = body.split(/,/)
        selected_results = results_array.values_at(0, 5, 7, 8)
        Hash[keys.zip selected_results]
      end
  end
end
