require "spec_helper"

describe PvOutputWrapper::Response do
  before do
    @request = PvOutputWrapper::Request.new('my_api_key', 'my_system_id')
  end

  describe 'parse' do
    context 'when the service is search' do
      let(:query) { {:q => 'sun'} }
      let(:body) do
        # rubocop:disable Metrics/LineLength
        "$-from-sun,3150,2155,N,224,235 weeks ago,149,Solar Enertec/SE175M,Xantrex GT2.8-AU,NaN,-33.703416,150.946875\n'aaah!' where's the Sun,4725,3173,N,1198,81 weeks ago,955,SunOwe SF125x125-72-M,Xantrex GT5.0-Au,NaN,-37.994502,145.17544\n"
        # rubocop:enable Metrics/LineLength
      end

      let!(:stub) { PvoStub.new('search', body, query) }
      let(:parsed_response) { @request.search('q' => 'sun').parse }

      let(:expected_response) do
        [{:system_name => "$-from-sun",
          :system_size => "3150",
          :postcode => "2155",
          :orientation => "N",
          :outputs => "224",
          :last_output => "235 weeks ago",
          :system_id => "149",
          :panel => "Solar Enertec/SE175M",
          :inverter => "Xantrex GT2.8-AU",
          :distance => "NaN",
          :latitude => "-33.703416",
          :longitude => "150.946875"},
         {:system_name => "'aaah!' where's the Sun",
          :system_size => "4725",
          :postcode => "3173",
          :orientation => "N",
          :outputs => "1198",
          :last_output => "81 weeks ago",
          :system_id => "955",
          :panel => "SunOwe SF125x125-72-M",
          :inverter => "Xantrex GT5.0-Au",
          :distance => "NaN",
          :latitude => "-37.994502",
          :longitude => "145.17544"}
        ]
      end

      it 'should assign the correct keys to each value' do
        expect(parsed_response).to eq(expected_response)
      end

      # describe 'param_keys' do
      #   let(:param_keys) { @request.search('q' => 'sun').param_keys }
      #   it 'should return param_keys' do
      #     expect(param_keys).to eq([:q])
      #   end
      # end
    end

    context 'when the service is unrecognised' do
      let!(:stub) { PvoStub.new('foo', '', {}) }
      let(:parsed_response) { @request.foo('q' => 'sun') }
      it 'should return an empty hash' do
        expect(parsed_response).to eq({})
      end

      it 'should raise an error' do
        expect(parsed_response).to raise_error
      end
    end
  end

  describe 'get_statistic' do
    let(:query) { {:df => '20150101'} }
    let(:body) { "246800,246800,8226,2000,11400,3.358,27,20100901,20100927,4.653,20100916" }
    let!(:stub) { PvoStub.new('getstatistic', body, query) }
    let(:parsed_response) { @request.get_statistic(:df => '20150101').parse }
    let(:expected_response) do
      {
        :energy_generated => "246800",
        :energy_exported => "246800",
        :average_generation => "8226",
        :minimum_generation => "2000",
        :maximum_generation => "11400",
        :average_efficiency => "3.358",
        :outputs => "27",
        :actual_date_from => "20100901",
        :actual_date_to => "20100927",
        :record_efficiency => "4.653",
        :record_date => "20100916",
        :energy_consumed => nil,
        :peak_energy_import => nil,
        :off_peak_energy_import => nil,
        :shoulder_energy_import => nil,
        :high_shoulder_energy_import => nil,
        :average_consumption => nil,
        :minimum_consumption => nil,
        :maximum_consumption => nil,
        :credit_amount => nil,
        :debit_amount => nil,
      }
    end

    it 'should return a hash' do
      expect(parsed_response).to eq(expected_response)
    end
  end
end
