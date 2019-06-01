require 'open3'
require 'json'
require 'base64'
require 'net/http'
require 'uri'

$max_size = 5 * 1024 * 1024
$image_types = /image\/(jpeg|png|bmp)/

def lambda_handler(event:, context:)
  begin
    url = event.dig('queryStringParameters', 'url')
    check_url(url)

    puts "pickling url: #{url.inspect}"
    pickle, status = Open3.capture2("./pickle_image.sh #{url}")
    puts "return status is: #{status}"

    {
      statusCode: 200,
      headers: { 'Content-Type': 'image/png' },
      isBase64Encoded: true,
      body: Base64.encode64(pickle)
    }
  rescue => e
    {
      statusCode: 400,
      body: e.message
    }
  end
end

def check_url(url)
  uri = URI.parse(url)
  request = Net::HTTP::Head.new(uri)

  req_options = {
    use_ssl: uri.scheme == "https"
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  
  unless response.code.to_i == 200
    raise "failed to retrieve image"
  end
  
  unless response.content_type.match?($image_types)
    raise "bad file type: #{response.content_type}"
  end

  if response.content_length > $max_size
    raise "file too large: #{response.content_length}"
  end
end
