require 'bundler/setup'
require 'sinatra/base'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'yt'
require 'addressable/uri'
require 'twitter'
require 'unwind'
require 'nokogiri'
require_relative 'lib/credentials'

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

    "All set! Your credentials have been stored for future use."
  end

  get '/auth/failure' do
    content_type 'text/plain'
    request.env['omniauth.auth'].to_hash.inspect rescue "An error occurred while processing your authorization."
  end

  get '/watchlater' do
    content_type 'text/plain'
    begin
      if video_id = extract(params[:url])
        playlist = Yt::Playlist.new(id: 'WL', auth: Credentials.youtube_account)
        playlist.add_video(video_id)

        'OK'
      else
        'OOPS: Invalid URL'
      end
    rescue Yt::Errors::RequestError => e
      if e.reasons && e.reasons.include?('videoAlreadyInPlaylist')
        'OK'
      else
        "OOPS: #{e.response_body['error']['message']}"
      end
    rescue => e
      "OOPS: #{e.message}"
    end
  end

  helpers do
    def extract(url)
      logger.debug "extract=#{url}"
      final_url = follow(url)

      logger.debug "final=#{final_url}"

      if final_url =~ /youtube\.com/
        uri = Addressable::URI.parse(final_url)
        uri.query_values['v']
      elsif final_url =~ /youtu\.be/
        uri = Addressable::URI.parse(final_url)
        uri.path[1..-1]
      elsif final_url =~ /twitter\.com/
        embedded_tweet = twitter_client.oembed(final_url, omit_script: true)
        content_url = extract_from_embedded_tweet(embedded_tweet.html)
        extract(content_url)
      end
    end

    def follow(url)
      follower = Unwind::RedirectFollower.new(url)
      follower.resolve
      follower.final_url
    end

    def extract_from_embedded_tweet(tweet_body)
      html_doc = Nokogiri::HTML(tweet_body)
      html_doc.css('a').each do |link|
        return link['href'].to_s if link['href'].to_s =~ /t\.co/
      end
    end

    def twitter_client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
      end
    end
  end
end
