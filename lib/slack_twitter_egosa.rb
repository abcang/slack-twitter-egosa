require 'slack_twitter_egosa/version'
require 'slack_twitter_egosa/slack_poster'
require 'slack_twitter_egosa/word_manager'
require 'slack_twitter_egosa/user_filter'

require 'dotenv'
require 'twitter'

module SlackTwitterEgosa
  class << self
    def run(envfile)
      Dotenv.load(envfile) if envfile

      lack_env = check_env(ENV.keys)
      unless lack_env.empty?
        STDERR.puts 'Not enough vnvironment variable'
        lack_env.each do |env|
          STDERR.puts "  #{env}"
        end
        exit 1
      end

      threads = [
        home_timeline_thread,
        search_thread
      ]
      threads.each(&:join)
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
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['CONSUMER_KEY']
        config.consumer_secret     = ENV['CONSUMER_SECRET']
        config.access_token        = ENV['OAUTH_TOKEN']
        config.access_token_secret = ENV['OAUTH_TOKEN_SECRET']
      end
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
      if status.retweet?
        status = status.retweeted_status
        return false if status.user.following?
      end

      mute_users.unmatch?(status.user.screen_name) && home_timeline_words.match?(CGI.unescapeHTML(status.attrs[:full_text]))
    end

    def match_on_search?(status)
      !status.retweet? && mute_users.unmatch?(status.user.screen_name) &&
        search_words.unmatch_exclude?(CGI.unescapeHTML(status.attrs[:full_text]))
    end

    def home_timeline_thread
      Thread.new do
        loop do
          sleep 90 if @home_timeline_since_id

          params = { count: 200, tweet_mode: 'extended' }
          params[:since_id] = @home_timeline_since_id if @home_timeline_since_id
          statuses = client.home_timeline(params)
          next if statuses.empty?

          before_home_timeline_since_id = @home_timeline_since_id
          @home_timeline_since_id = statuses.first.id
          next unless before_home_timeline_since_id

          statuses.reverse_each do |status|
            poster.post_status(status) if match_on_home_timeline?(status)
          end
        end
      end
    end

    def search_thread
      Thread.new do
        loop do
          sleep 90 if @search_since_id

          params = { result_type: 'recent', count: 100, tweet_mode: 'extended' }
          params[:since_id] = @search_since_id if @search_since_id
          statuses = client.search(search_words.query, params).to_a
          next if statuses.empty?

          before_search_since_id = @search_since_id
          @search_since_id = statuses.first.id
          next unless before_search_since_id

          statuses.reverse_each do |status|
            poster.post_status(status) if match_on_search?(status)
          end
        end
      end
    end
  end
end
