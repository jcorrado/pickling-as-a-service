require 'open3'
require 'json'

def lambda_handler(event:, context:)

  begin
    url = event['queryStringParameters']['url']
  rescue
    url = nil
  end

  puts "pickling url: #{url}"
  pickle, status = Open3.capture2("./pickle_image.sh #{url} | base64")

  puts "return status is: #{status}"

  {
    statusCode: 200,
    headers: { 'Content-Type': 'image/png' },
    isBase64Encoded: true,
    body: pickle
  }
end
