# frozen_string_literal: true

require 'twitter'

class TwitterClient
  def initialize(consumer_key:, consumer_secret:, access_token:, access_token_secret:, search_query:)
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = consumer_key
      config.consumer_secret     = consumer_secret
      config.access_token        = access_token
      config.access_token_secret = access_token_secret
    end
    @search_query = search_query
  end

  def home_timeline
    is_first_fetch = @home_timeline_since_id.nil?

    params = { count: 200, tweet_mode: 'extended' }
    params[:since_id] = @home_timeline_since_id if @home_timeline_since_id
    statuses = @client.home_timeline(params).to_a
    @home_timeline_since_id = statuses.first.id unless statuses.empty?

    # Tweets acquired for the first time are not subject to notification
    return [] if is_first_fetch

    statuses
  rescue Twitter::Error::TooManyRequests, HTTP::ConnectionError => e
    warn "home_timeline: #{e.inspect}"
    []
  end

  def search
    return [] if @search_query.empty?

    is_first_fetch = @search_since_id.nil?

    params = { result_type: 'recent', count: 100, tweet_mode: 'extended' }
    params[:since_id] = @search_since_id if @search_since_id
    statuses = @client.search(@search_query, params).to_a
    @search_since_id = statuses.first.id unless statuses.empty?

    # Tweets acquired for the first time are not subject to notification
    return [] if is_first_fetch

    statuses
  rescue Twitter::Error::TooManyRequests, HTTP::ConnectionError => e
    warn "search: #{e.inspect}"
    []
  end
end
