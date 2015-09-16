module PvOutputWrapper
  class Response
    attr_reader :response

    def initialize(service, response)
      @service = service
      @response = response
    end

    # @return [String]
    def body
      @response.body
    end

    # TODO: raise exception
    def parse
      method(@service).call
    rescue NoMethodError
      {}
      raise 'Unsupported service.'
    end

    private

    # @return [Hash<String, >] system data or nil values upon failure.
    # :total_output is in watt hours.
    def get_statistic
      keys = [:total_output, :efficiency, :date_from, :date_to]
      selected_results = body.split(/,/).values_at(0, 5, 7, 8)
      Hash[keys.zip selected_results]
    end
  end
end
