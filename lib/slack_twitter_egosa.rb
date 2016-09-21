require 'slack_twitter_egosa/version'
require 'slack_twitter_egosa/slack_poster'
require 'slack_twitter_egosa/word_manager'
require 'slack_twitter_egosa/user_filter'

require 'dotenv'
require 'tweetstream'

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

      init_twitter

      threads = [
        user_stream_thread,
        filter_stream_thread
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

    def init_twitter
      TweetStream.configure do |config|
        config.consumer_key       = ENV['CONSUMER_KEY']
        config.consumer_secret    = ENV['CONSUMER_SECRET']
        config.oauth_token        = ENV['OAUTH_TOKEN']
        config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
        config.auth_method        = :oauth
      end
    end

    def poster
      @poster ||= SlackPoster.new(ENV['WEBHOOK_URL'])
    end

    def user_stream
      @user_stream ||= WordManager.new(ENV['USER_STREAM_WORDS'])
    end

    def filter_stream
      @filter_stream ||= WordManager.new(ENV['FILTER_STREAM_WORDS'])
    end

    def mute_users
      @mute_users ||= UserFilter.new(ENV['MUTE_USERS'])
    end

    def user_stream_thread
      Thread.new do
        TweetStream::Client.new.userstream do |status|
          if status.retweet?
            status = status.retweeted_status
            next if status.user.following?
          end

          if mute_users.unmatch?(status.user.screen_name) &&
              user_stream.match?(CGI.unescapeHTML(status.full_text))
            poster.post_status(status)
          end
        end
      end
    end

    def filter_stream_thread
      Thread.new do
        TweetStream::Client.new.track(*filter_stream.target) do |status|
          if !status.retweet? && mute_users.unmatch?(status.user.screen_name) &&
              filter_stream.unmatch_exclude?(CGI.unescapeHTML(status.full_text))
            poster.post_status(status)
          end
        end
      end
    end
  end
end
