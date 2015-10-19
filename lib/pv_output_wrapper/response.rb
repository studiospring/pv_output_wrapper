module PvOutputWrapper
  require 'addressable/uri'

  class Response
    attr_reader :response

    SERVICE_MAPPER = {
      # rubocop:disable Metrics/LineLength
      :get_statistic => %i(energy_generated energy_exported average_generation  minimum_generation maximum_generation average_efficiency outputs actual_date_from actual_date_to record_efficiency record_date energy_consumed peak_energy_import off_peak_energy_import shoulder_energy_import high_shoulder_energy_import average_consumption minimum_consumption maximum_consumption credit_amount debit_amount),
      :get_status => %i(date time energy_generation power_generation energy_consumption power_consumption efficiency temperature voltage extended_value1 extended_value2 extended_value3 extended_value4 extended_value5 extended_value6),
      :get_system => %i(field system_name system_size postcode number_of_panels panel_power panel_brand number_of_inverters inverter_power inverter_brand orientation array_tilt shade install_date latitude longitude status_interval number_of_panels_secondary panel_power_secondary orientation_secondary array_tilt_secondary export_tariff import_peak_tariff import_off_peak_tariff import_shoulder_tariff import_high_shoulder_tariff import_daily_charge teams donations extended_data_config monthly_estimations),
      :search => %i(system_name system_size postcode orientation outputs last_output system_id panel inverter distance latitude longitude),
      # rubocop:enable Metrics/LineLength
    }

    # @arg [Addressable::URI], [Net::HTTPOK].
    def initialize(uri, response)
      @uri = uri
      @response = response
    end

    # @return [String].
    def body
      @response.body.encode('UTF-8', { :invalid => :replace,
                                       :undef => :replace,
                                       :replace => '?',
                                     }
                           )
    end

    # TODO: response body changes depending on params!
    # TODO: fix specs
    # TODO: raise exception
    # @return [Hash], [Array] data mapped to keys.
    def parse
      # if body.chomp!
      if body.include?("\n")
        parse_multi_line
      else
        parse_line(response_keys, body)
      end
    end

    private

    # @arg [Array<Symbol>] keys for the hash.
    # [String] one line of the response body.
    # @return [Hash].
    def parse_line(keys, line)
      Hash[keys.zip line.split(/,/)]
    end

    # @return [Array].
    def parse_multi_line
      keys = response_keys
      raise hell unless keys

      body.split("\n").reduce([]) do |a, line|
        a << parse_line(keys, line)
      end
    end

    # @return [Array<Symbol>].
    def response_keys
      SERVICE_MAPPER[service]
    end

    # @return [Symbol].
    def service
      @uri.path.split('/').last.split('.').first.to_sym
    end

    # @return [Array<Symbol>].
    def param_keys
      @uri.query_values.keys.flat_map(:to_sym)
    end
  end
end
