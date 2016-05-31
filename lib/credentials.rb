require 'redis'

module Credentials
  class InvalidYoutubeCredentials < StandardError ; end

  extend self

  def redis?
    !!@redis
  end

  def redis
    @redis ||= Redis.new(url: ENV["REDISTOGO_URL"])
  end

  def redis=(redis)
    @redis = redis
  end

  def from_omniauth(auth)
    puts auth['credentials'].inspect

    Credentials.redis.mapped_hmset('watch-later-credentials', {
      access_token: auth['credentials']['token'],
      refresh_token: auth['credentials']['refresh_token'],
      expires_at: auth['credentials']['expires_at'],
    })
  end

  def youtube_account
    creds = Credentials.redis.hgetall('watch-later-credentials')
    if creds
      Yt::Account.new(creds.symbolize_keys.slice(:access_token, :refresh_token, :expires_at))
    else
      raise InvalidYoutubeCredentials
    end
  end
end
