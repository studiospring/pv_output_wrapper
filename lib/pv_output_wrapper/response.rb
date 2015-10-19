module PvOutputWrapper
  class Response
    attr_reader :response

    def initialize(service, response)
      @service = service
      @response = response
    end

    # @return [String]
    def body
      @response.body.encode('UTF-8', { :invalid => :replace,
                                       :undef => :replace,
                                       :replace => '?',
      }
                           )
    end

    # This does not work because response.body is a String.
    # TODO: raise exception
    def parse
      method(@service).call
    rescue NoMethodError
      {}
      raise 'Unsupported service.'
    end

    private

    # @return [Hash{Symbol => <String>}] .
    def search
      keys = %i(system_name system_size postcode orientation outputs last_output system_id panel inverter distance latitude longitude)

      results = []
      body.split("\n").each do |system_string|
        # merges keys and system data to hash
        results << Hash[keys.zip system_string.split(/,/)]
      end

      # postcode = Postcode.find_by :pcode => query.split(' ')[0]

      # if postcode
      #   postcode.update_urban if postcode.update_urban?(results)
      # end

      results
    end

    # @return [Hash<String, >] system data or nil values upon failure.
    # :total_output is in watt hours.
    def get_statistic
      keys = [:total_output, :efficiency, :date_from, :date_to]
      selected_results = body.split(/,/).values_at(0, 5, 7, 8)
      Hash[keys.zip selected_results]
    end
  end
end
