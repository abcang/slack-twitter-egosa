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

user_stream_words = []
user_stream_words_exclude = []
ENV['USER_STREAM_WORDS'].to_s.dup.force_encoding('utf-8').split(' ').each do |word|
  if word.start_with?('-')
    user_stream_words_exclude << word[1..-1]
  else
    user_stream_words << word
  end
end

filter_stream_words = []
filter_stream_words_exclude = []
ENV['FILTER_STREAM_WORDS'].to_s.dup.force_encoding('utf-8').split(' ').each do |word|
  if word.start_with?('-')
    filter_stream_words_exclude << word[1..-1]
  else
    filter_stream_words << word
  end
end

mute_users = ENV['MUTE_USERS'].to_s.downcase.split(' ')

threads << Thread.new do
  TweetStream::Client.new.userstream do |status|
    if status.retweet?
      status = status.retweeted_status
      next if status.user.following?
    end

    full_text = CGI.unescapeHTML(status.full_text)
    if !mute_users.include?(status.user.screen_name.downcase) &&
        full_text =~ /#{user_stream_words.join('|')}/ &&
        !(full_text =~ /#{user_stream_words_exclude.join('|')}/) &&
      poster.post_status(status)
    end
  end
end

threads << Thread.new do
  TweetStream::Client.new.track(*filter_stream_words) do |status|
    if !status.retweet? && !mute_users.include?(status.user.screen_name.downcase) &&
        !(CGI.unescapeHTML(status.full_text) =~ /#{filter_stream_words_exclude.join('|')}/) &&
      poster.post_status(status)
    end
  end
end

threads.each(&:join)
