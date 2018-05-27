# frozen_string_literal: true

require 'slack/poster'

class SlackPoster
  def initialize(url)
    @poster = Slack::Poster.new(url)
    @locker = Mutex::new
    @pushed_ids = []
  end

  def post_status(status)
    @locker.synchronize do
      unless pushed?(status.id)
        @poster.icon_url = status.user.profile_image_url
        @poster.username = "#{status.user.name}(@#{status.user.screen_name})"
        @poster.send_message("#{status.attrs[:full_text]}\n#{status.url}")
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
