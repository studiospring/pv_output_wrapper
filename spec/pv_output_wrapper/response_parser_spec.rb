require "spec_helper"

describe PvOutputWrapper::ResponseParser do
  describe 'get_statistic' do
    before do
      request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
      response = request.get_statistic(:df => '20150101')
      @parsed_response = response.parse
    end

    it 'should return a hash' do
      system_stats = {
        'total_output' => '246800',
        'efficiency' => '3.358',
        'date_from' => '20100901',
        'date_to' => '20100927'
        }

      expect(@parsed_response).to eq(system_stats)
    end
  end
end
