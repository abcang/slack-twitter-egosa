require 'spec_helper'

describe SlackTwitterEgosa do
  it 'has a version number' do
    expect(SlackTwitterEgosa::VERSION).not_to be nil
  end

  it 'checks environment variable' do
    env = %w(
      CONSUMER_KEY
      CONSUMER_SECRET
      OAUTH_TOKEN
      OAUTH_TOKEN_SECRET
      WEBHOOK_URL
    )
    expect(SlackTwitterEgosa.send(:check_env, [])).to eq(env)
    expect(SlackTwitterEgosa.send(:check_env, env)).to eq([])
  end
end
