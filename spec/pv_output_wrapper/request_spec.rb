require "spec_helper"
require "addressable/uri"

describe PvOutputWrapper::Request do
  let(:expected_body) { "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916" }
  before do
    # Malformed uri is to correct a Webmock/Addressable bug.
    @request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
  end

  describe 'method_missing' do
    context 'when no params are entered' do
      let(:expected_body) do
        "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916"
      end

      let!(:stub) { PvoStub.new('getstatistic', expected_body) }

      it "should return the correct response body." do
        expect(@request.get_statistic.body).to eq(expected_body)
      end
    end

    context 'when some params are entered' do
      let(:query) { {:df => '20150101'} }
      let!(:stub) { PvoStub.new('getstatistic', expected_body, query) }

      it "should return the correct response body." do
        expect(@request.get_statistic(:df => '20150101').body).to eq(expected_body)
      end
    end

    context 'when an unrecognised service is requested' do
      it 'should raise a NoMethodError error' do
        expect { @request.foobar }.to raise_error(NoMethodError)
      end

      context 'and the method takes an argument' do
        it 'should raise a NoMethodError error' do
          expect { @request.foobar('param') }.to raise_error(NoMethodError)
        end
      end
    end

    context 'when invalid params are entered' do
      let(:query) { {:foo => 'bar'} }
      let!(:stub) { PvoStub.new('getstatistic', expected_body, query) }

      it 'should raise an error' do
        expect { @request.get_statistic(:foo => 'bar') }.to raise_error(ArgumentError)
      end
    end

    context 'when required headers are missing' do
      # This spec is unnecessary since initializing the Request object without
      #   header arguments will raise an ArgumentError.
    end

    context 'when there is no response' do
      skip
    end
  end
end
