class UserFilter
  attr_reader :mute_users

  def initialize(users_text)
    @mute_users = users_text.to_s.downcase.split(' ')
  end

  def match?(screen_name)
    mute_users.include?(screen_name.downcase)
  end

  def unmatch?(screen_name)
    !match?(screen_name)
  end
end
