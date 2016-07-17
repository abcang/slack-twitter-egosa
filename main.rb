# -*- coding: utf-8 -*-
require 'singleton'
require 'bundler/setup'
require 'dotenv'
require 'tweetstream'
require 'slack/poster'

Dotenv.load

TweetStream.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
  config.auth_method        = :oauth
end

class SlackPoster
  include Singleton

  def initialize
    @poster = Slack::Poster.new(ENV['WEBHOOK_URL'])
    @locker = Mutex::new
    @pushed_ids = []
  end

  def post_status(status)
    @locker.synchronize do
      unless pushed?(status.id)
        @poster.icon_url = status.user.profile_image_url
        @poster.username = "#{status.user.name}(@#{status.user.screen_name})"
        @poster.send_message("#{status.full_text}\n#{status.url}")
        push(status.id)
      end
    end
  end

  private

  def pushed?(id)
    @pushed_ids.include?(id)
  end

  def push(id)
    @pushed_ids.push(id)
    @pushed_ids.shift if @pushed_ids.size > 50
  end
end

poster = SlackPoster.instance
threads = []

user_stream_words = ENV['USER_STREAM_WORDS'].dup.force_encoding('utf-8').split(' ')
filter_stream_words = ENV['FILTER_STREAM_WORDS'].dup.force_encoding('utf-8').split(' ')

threads << Thread.new do
  TweetStream::Client.new.userstream do |status|
    if status.retweet?
      status = status.retweeted_status
      next if status.user.following?
    end
    if CGI.unescapeHTML(status.full_text) =~ /#{user_stream_words.join('|')}/
      poster.post_status(status)
    end
  end
end

threads << Thread.new do
  TweetStream::Client.new.track(*filter_stream_words) do |status|
    poster.post_status(status) unless status.retweet?
  end
end

threads.each { |t| t.join }
