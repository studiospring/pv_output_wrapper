require "spec_helper"

describe PvOutputWrapper::Response do
  before do
    @request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
  end

  describe 'get_statistic' do
    let(:query) { {:df => '20150101'} }
    let(:body) { "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916" }
    let!(:stub) { PvoStub.new('getstatistic', body, query) }
    let(:parsed_response) { @request.get_statistic(:df => '20150101').parse }
    let(:expected_response) do
      {
        :total_output => '246800',
        :efficiency => '3.358',
        :date_from => '20100901',
        :date_to => '20100927',
      }
    end

    it 'should return a hash' do
      expect(parsed_response).to eq(expected_response)
    end
  end
end
