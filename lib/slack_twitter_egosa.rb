# frozen_string_literal: true

require 'thwait'

require_relative 'slack_twitter_egosa/version'
require_relative 'slack_twitter_egosa/slack_poster'
require_relative 'slack_twitter_egosa/word_manager'
require_relative 'slack_twitter_egosa/user_filter'
require_relative 'slack_twitter_egosa/twitter_client'

require 'dotenv'

module SlackTwitterEgosa
  class << self
    def run(envfile)
      Dotenv.load(envfile) if envfile

      lack_env = check_env(ENV.keys)
      unless lack_env.empty?
        warn 'Not enough vnvironment variable'
        lack_env.each do |env|
          warn "  #{env}"
        end
        exit 1
      end

      Thread.abort_on_exception = true
      threads = []
      threads << home_timeline_thread unless home_timeline_words.query.empty?
      threads << search_thread unless search_words.query.empty?
      ThreadsWait.all_waits(*threads)
    end

    private

    def check_env(env_list)
      target_env = %w(
        CONSUMER_KEY
        CONSUMER_SECRET
        OAUTH_TOKEN
        OAUTH_TOKEN_SECRET
        WEBHOOK_URL
      )
      target_env - env_list
    end

    def client
      @client ||= TwitterClient.new(
        consumer_key: ENV['CONSUMER_KEY'],
        consumer_secret: ENV['CONSUMER_SECRET'],
        access_token: ENV['OAUTH_TOKEN'],
        access_token_secret: ENV['OAUTH_TOKEN_SECRET'],
        search_query: search_words.query
      )
    end

    def poster
      @poster ||= SlackPoster.new(ENV['WEBHOOK_URL'])
    end

    def home_timeline_words
      @home_timeline_words ||= WordManager.new(ENV['HOME_TIMELINE_WORDS'])
    end

    def search_words
      @search_words ||= WordManager.new(ENV['SEARCH_WORDS'])
    end

    def mute_users
      @mute_users ||= UserFilter.new(ENV['MUTE_USERS'])
    end

    def match_on_home_timeline?(status)
      mute_users.unmatch?(status.user.screen_name) && home_timeline_words.match?(CGI.unescapeHTML(status.attrs[:full_text]))
    end

    def match_on_search?(status)
      !status.retweet? && mute_users.unmatch?(status.user.screen_name) &&
        search_words.unmatch_exclude?(CGI.unescapeHTML(status.attrs[:full_text]))
    end

    def home_timeline_thread
      Thread.new do
        loop do
          client.home_timeline.reverse_each do |status|
            if status.retweet?
              status = status.retweeted_status
              next if status.user.following?
            end

            poster.post_status(status) if match_on_home_timeline?(status)
          end

          # Max 15 requests / 15 min
          sleep 180
        end
      end
    end

    def search_thread
      Thread.new do
        loop do
          client.search.reverse_each do |status|
            poster.post_status(status) if match_on_search?(status)
          end

          # Max 180 requests / 15 min
          sleep 60
        end
      end
    end
  end
end
