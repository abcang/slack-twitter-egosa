FROM ruby:latest

MAINTAINER ABCanG <abcang1015@gmail.com>

# timezone
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN gem install slack_twitter_egosa

CMD ["slack_twitter_egosa"]
