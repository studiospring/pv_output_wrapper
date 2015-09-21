require 'addressable/uri'
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
    @query = params || {}
    @body = body
    stub
  end

  # @return [Webmock::API.stub_request].
  def stub
    stub_request(:get, construct_uri)
      .with(:headers => headers)
      .to_return(:status => 200, :body => @body, :headers => {})
  end

  # @return [Addressable::URI].
  def construct_uri
    uri = "http://http//www.pvoutput.org:80/service/r2/#{@service}.jsp/{?query*}"
    template = Addressable::Template.new(uri)
    template.expand({'query' => @query})
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
