require "spec_helper"
require "addressable/uri"

describe PvOutputWrapper::Request do
  describe 'get_statistic' do
    before do
      @request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
      request_uri = "http://www.pvoutput.org/service/r2/getstatistic.jsp/?foo=bar"
      response_body = "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916"
      headers = {'Accept'=>'*/*',
                 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                 'User-Agent'=>'Ruby',
                 'X-Pvoutput-Apikey'=>'my_api_key',
                 'X-Pvoutput-Systemid'=>'my_system_id'
                }

      stub_request(:get, request_uri).
        with(:headers => headers).
        to_return(:status => 200, :body => response_body)
    end

    context 'when no params are entered' do
      it "should return a string" do
        expect(@request.get_statistic).to eq('string')
      end
    end

    context 'when some params are entered' do
      it "should return a string" do
        expect(@request.get_statistic({'foo' => 'bar'})).to eq('string')
      end
    end

    context 'when invalid params are entered' do
    end

    describe 'should have required headers' do
    end
  end
end
