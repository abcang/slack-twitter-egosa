FROM ruby:latest

MAINTAINER ABCanG <abcang1015@gmail.com>

# timezone
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --deployment

COPY . /app

CMD ruby ./main.rb'
