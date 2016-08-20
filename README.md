slack-twitter-egosa
===

TwitterでエゴサしてSlackに投稿します。

## 環境
* Bundler
* Ruby

## 設定
各環境変数に値を設定します

* `WEBHOOK_URL`: 投稿先のslackのIncoming WebhooksのURL
* `CONSUMER_KEY`: TwitterのConsumer Key
* `CONSUMER_SECRET`: TwitterのConsumer Secret
* `OAUTH_TOKEN`: TwitterのAccess Token
* `OAUTH_TOKEN_SECRET`: TwitterのAccess Token Secret
* `USER_STREAM_WORDS`: 自分のタイムラインから検索するワード。スペース区切りで複数指定可。
* `FILTER_STREAM_WORDS`: Twitter全体から検索するワード。スペース区切りで複数指定可。


## 普通に起動

```bash
$ git clone https://github.com/ABCanG/slack-twitter-egosa.git
$ cd slack-twitter-egosa
$ bundle install --path vendor/bundle
$ cat > .env
WEBHOOK_URL=https://hooks.slack.com/services/XXXXXXXX/XXXXXXXX/XXXXXXXX
CONSUMER_KEY=XXXXXXXX
CONSUMER_SECRET=XXXXXXXX
OAUTH_TOKEN=XXXXXXXX
OAUTH_TOKEN_SECRET=XXXXXXXX
USER_STREAM_WORDS=阿部 あべ
FILTER_STREAM_WORDS=abcang
^D
$ ruby main.rb
```

## Dockerを使って起動

```bash
docker run \
    -e "WEBHOOK_URL=https://hooks.slack.com/services/XXXXXXXX/XXXXXXXX/XXXXXXXX" \
    -e "CONSUMER_KEY=XXXXXXXX" \
    -e "CONSUMER_SECRET=XXXXXXXX" \
    -e "OAUTH_TOKEN=XXXXXXXX" \
    -e "OAUTH_TOKEN_SECRET=XXXXXXXX" \
    -e "USER_STREAM_WORDS=阿部 あべ" \
    -e "FILTER_STREAM_WORDS=abcang" \
    abcang/slack-twitter-egosa
```

## ライセンス
MIT
