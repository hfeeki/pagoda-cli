require 'webmock/rspec'

include WebMock::API

def stub_api_request(method, path)
  stub_request(method, "https://api.pagodagrid.com#{path}")
end