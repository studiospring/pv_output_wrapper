require "spec_helper"

describe PvOutputWrapper::Response do
  before do
    # Malformed uri is to correct a Webmock/Addressable bug.
    @base_uri = "http://http//www.pvoutput.org:80/service/r2/"
    @request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
    @headers = {'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby',
                'X-Pvoutput-Apikey' => 'my_api_key',
                'X-Pvoutput-Systemid' => 'my_system_id'
              }
  end

  describe 'get_statistic' do
    before do
      response_body = "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916"
      uri = @base_uri + "getstatistic.jsp/?df=20150101"
      stub_request(:get, uri)
        .with(:headers => @headers)
        .to_return(:status => 200, :body => response_body)
      response = @request.get_statistic(:df => '20150101')
      @parsed_response = response.parse
    end

    it 'should return a hash' do
      system_stats = {
        :total_output => '246800',
        :efficiency => '3.358',
        :date_from => '20100901',
        :date_to => '20100927'
      }

      expect(@parsed_response).to eq(system_stats)
    end
  end
end
