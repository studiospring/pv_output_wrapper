require "spec_helper"
require "addressable/uri"

describe PvOutputWrapper::Request do
  describe 'get_statistic' do
    before do
      # Malformed uri is to correct a Webmock/Addressable bug.
      @base_uri = "http://http//www.pvoutput.org:80/service/r2/"
      @request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
      @response_body = "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916"
      @headers = {'Accept'=>'*/*',
                 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                 'User-Agent'=>'Ruby',
                 'X-Pvoutput-Apikey'=>'my_api_key',
                 'X-Pvoutput-Systemid'=>'my_system_id'
                }
    end

    context 'when no params are entered' do
      before do
        uri = @base_uri + "getstatistic.jsp/"
        stub_request(:get, uri).
          with(:headers => @headers).
          to_return(:status => 200, :body => @response_body)
      end

      it "should return the correct response body." do
        expect(@request.get_statistic).to eq(@response_body)
      end
    end

    context 'when some params are entered' do
      before do
        uri = @base_uri + "getstatistic.jsp/?foo=bar"
        stub_request(:get, uri).
          with(:headers => @headers).
          to_return(:status => 200, :body => @response_body)
      end

      it "should return the correct response body." do
        expect(@request.get_statistic({'foo' => 'bar'})).to eq(@response_body)
      end
    end

    context 'when invalid params are entered' do
    end

    describe 'should have required headers' do
    end
  end
end
