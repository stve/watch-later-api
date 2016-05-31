require 'bundler/setup'
require 'sinatra/base'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'yt'
require_relative 'lib/credentials'

Yt.configure do |config|
  config.client_id = ENV['YT_CLIENT_ID']
  config.client_secret = ENV['YT_CLIENT_SECRET']
end

class App < Sinatra::Base
  use Rack::Session::Cookie, secret: ENV['RACK_COOKIE_SECRET']

  use OmniAuth::Builder do
    provider :google_oauth2, ENV['YT_CLIENT_ID'], ENV['YT_CLIENT_SECRET'], { scope: 'email, profile, youtube' }
  end

  get '/' do
    redirect 'https://github.com/stve/watch-later'
  end

  get '/auth/:provider/callback' do
    content_type 'text/plain'
    Credentials.from_omniauth(request.env['omniauth.auth'].to_hash)
  end

  get '/auth/failure' do
    content_type 'text/plain'
    request.env['omniauth.auth'].to_hash.inspect rescue "No Data"
  end

  get '/watchlater' do
    playlist = Yt::Playlist.new(id: 'WL', auth: Credentials.youtube_account)
    playlist.add_video params[:v]

    'OK'
  end
end
