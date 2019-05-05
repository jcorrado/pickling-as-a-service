require 'sinatra'
require 'sinatra/reloader'

get "/pickle", provides: :png do
  %x{ ./pickle_image.sh #{params['url']} }
end
