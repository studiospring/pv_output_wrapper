module PvOutputWrapper
  class Query

    def initialize(api_key, system_id)
      @api_key = api_key
      @system_id = system_id

      @significance = 0
      # from search
      @id = similar_system['id']
      @system_watts = similar_system['system_watts']
      @postcode = similar_system['postcode']
      @entries = similar_system['entries']
      @date_to = similar_system['last_entry']
      @orientation = similar_system['orientation']
      # from get_system
      @date_from = similar_system['install_date']
      @shade = similar_system['shade']
      @tilt = similar_system['tilt']
      # from get_statistic
      @total_output = similar_system['total_output']
      @efficiency = nil
    end

    # # @return output_pa divided by system_watts (Wh).
    # def output_per_system_watts
    #   output = self.output_pa / self.system_watts.to_i
    # rescue
    #   0
    # else
    #   output
    # end

    # # @return [Float] actual average annual output (Wh) from pvo's energy generated.
    # # TODO: does not check for missing data
    # def output_pa
    #   date_from = Date.parse(self.date_from)
    #   date_to = Date.parse(self.date_to)
    #   entries_period = (date_to - date_from).to_i # in days

    #   if entries_period >= 365
    #     # Find date exactly n years before date_to.
    #     year_count = (entries_period / 365).to_i
    #     start_date = (date_to - year_count.years).strftime('%Y%m%d')
    #     query_params = { :sid1 => self.id, :date_from => start_date, :date_to => self.date_to }
    #     stats = self.class.get_statistic(query_params)
    #     stats['total_output'].to_i / year_count
    #   end
    # end

    # # Assign missing attributes, using data from get_statistic.
    # # Failure assigns nil values.
    # def get_stats
    #   query_params = { :sid1 => self.id }
    #   stats = self.class.get_statistic(query_params)
    #   # udpate date_from to use 'actual date from', not 'install date'
    #   self.date_from = stats['date_from']
    #   self.date_to = stats['date_to']
    #   self.total_output = stats['total_output']
    # end

    # # Use pv_query.pvo_search_params to generate query argument.
    # # @return [Hash] of most similar and statistically reliable system
    # #   with data from both search and get_system (or nil).
    # # TODO: loop and change search params if it returns nil?
    # def self.find_similar_system(pvo_search_params)
    #   candidate_systems = self.search(pvo_search_params)
    #   # order by number of entries
    #   candidate_systems.sort! { |a, b| a['entries'] <=> b['entries'] }
    #   # limit times get_system can be called
    #   top5 = candidate_systems[0, 5]
    #   shaded_systems = []

    #   top5.each do |system|
    #     # get rid of systems with secondary panels
    #     if system['entries'].to_i >= 100 && system['panel_count'] == 'NaN'
    #       system_info = self.get_system(system['id'])
    #       if system_info['shade'] == 'No'
    #         similar_system = system_info.merge(system)
    #         similar_system
    #       elsif system_info['shade'] == 'Low' # get one with low shade?
    #         shaded_systems << system_info.merge(system)
    #       end
    #     end
    #   end
    #   shaded_systems[0]
    # end

    # # http://pvoutput.org/help.html#search
    # # use pv_query.pvo_search_params to generate query argument
    # # Update postcode.urban attr depending on results count.
    # # @return [Array<Hash>] of systems [{name: 'some_name', size: 'size,...}, {...}]
    # #   or empty array.
    # def self.search(query)
    #   params = { 'q'        => query,
    #              'country'  => 'Australia' }
    #   response = self.request('search', params)
    #   response.chomp!
    #   results = []
    #   keys = ['name', 'system_watts', 'postcode', 'orientation', 'entries', 'last_entry', 'id', 'panel', 'inverter', 'distance', 'latitude', 'longitude']

    #   response.split("\n").each do |system_string|
    #     # merges keys and system data to hash
    #     results << Hash[keys.zip system_string.split(/,/)]
    #   end

    #   postcode = Postcode.find_by :pcode => query.split(' ')[0]
    #   postcode.update_urban if postcode.update_urban?(results)
    #   results
    # end

    # # @param [Fixnum]
    # # @return [Hash] of system info data.
    # def self.get_system(id)
    #   response = self.request('getsystem', {:sid1 => id})
    #   keys = %w(system_watts panel_count panel_watts orientation tilt shade install_date sec_panel_count sec_panel_watts sec_bearing sec_tilt)
    #   results_array = response.split(/,/)
    #   selected_results = results_array.values_at(1, 3, 4, 9, 10, 11, 12, 16, 17, 18, 19)
    #   # merges keys and system info to hash
    #   results = Hash[keys.zip selected_results]
    #   results['id'] = id
    #   results
    # end

    # # @return [Array<Hash>] daily output of system.
    # # Use to compare with theoretical daily output.
    # # Query_params include: 'df' (date from), 'dt' (date to), 'sid1'.
    # # TODO: untested, unfinished. Query by system id and date after donating
    # # unneeded?
    # def get_output
    #   response = self.request('getoutput', query_params)
    #   keys = ['date', 'output'] # output is in watt hours
    #   results = []

    #   response.split(/;/).each do |daily_output|
    #     results << Hash[keys.zip daily_output.values_at(0, 1)]
    #   end

    #   results
    # end

    # # @return [Hash<String, >] system data or nil values upon failure.
    # # Keep as class method for flexibility.
    # def self.get_statistic(query_params={})
    #   response = self.request('getstatistic', query_params)
    #   # total_output is in watt hours
    #   keys = ['total_output', 'efficiency', 'date_from', 'date_to']
    #   results_array = response.split(/,/)
    #   selected_results = results_array.values_at(0, 5, 7, 8)
    #   Hash[keys.zip selected_results]
    # end

    # # Make GET request to pvoutput api and return response (string).
    # def self.request(uri, params={})
    #   uri = URI.parse('http://pvoutput.org/service/r2/' + uri + '.jsp')
    #   auth_params = { 'key' => Rails.application.secrets.pvo_api_key,
    #                   'sid' => Rails.application.secrets.pvo_system_id }
    #   # Merge params params and add to uri.
    #   uri.query = URI.encode_www_form(auth_params.merge(params))
    #   begin
    #     response = uri.read
    #   rescue
    #     '' # fails silently
    #   else
    #     case response.status[0][0]
    #     when '2', '3'
    #       response
    #     else
    #       '' # fails silently
    #     end
    #   end
    # end
  end
end
