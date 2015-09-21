require 'webmock'
include WebMock::API

# Webmock does not parse non-alphanum chars (eg +) correctly,
#   nor does this class (except for spaces).
#   Therefore, you need to pass in params properly encoded.
# @arg [String], [String], [Hash].
# @return [Webmock::API.stub_request].
class PvoStub
  attr_reader :service, :query, :body

  def initialize(service, body, **params)
    @service = service
    @query = build_query(params)
    @body = body
    stub
  end

  # @return [Webmock::API.stub_request].
  def stub
    stub_request(:get, construct_uri)
      .with(:headers => headers)
      .to_return(:status => 200, :body => @body, :headers => {})
  end

  # @return [String] (should be addressable).
  def construct_uri
    "http://http//www.pvoutput.org:80/service/r2/#{@service}.jsp/#{@query}"
  end

  # @arg [Hash]
  # @return [String] query part of uri.
  def build_query(**params)
    ary = params.each_with_object([]) { |(k, v), s| s << "#{k}=#{v}" }
    ary.join('&').gsub(/\s/, '%20').prepend('?') unless ary.empty?
  end

  def headers
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Ruby',
      'X-Pvoutput-Apikey' => 'my_api_key',
      'X-Pvoutput-Systemid' => 'my_system_id',
    }
  end
end
