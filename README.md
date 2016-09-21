slack-twitter-egosa
===

[![Build Status](https://travis-ci.org/ABCanG/slack-twitter-egosa.svg?branch=master)](https://travis-ci.org/ABCanG/slack-twitter-egosa)
[![Gem Version](https://badge.fury.io/rb/slack_twitter_egosa.svg)](https://badge.fury.io/rb/slack_twitter_egosa)
[![](https://images.microbadger.com/badges/version/abcang/slack-twitter-egosa.svg)](http://microbadger.com/images/abcang/slack-twitter-egosa "Get your own version badge on microbadger.com")

TwitterでエゴサしてSlackに投稿します。

## 環境
* Bundler
* Ruby

## 設定
各環境変数に値を設定します。
検索ワードで指定した`-`から始まるワードは除外ワード扱いされます。

* `WEBHOOK_URL`: 投稿先のslackのIncoming WebhooksのURL
* `CONSUMER_KEY`: TwitterのConsumer Key
* `CONSUMER_SECRET`: TwitterのConsumer Secret
* `OAUTH_TOKEN`: TwitterのAccess Token
* `OAUTH_TOKEN_SECRET`: TwitterのAccess Token Secret
* `USER_STREAM_WORDS`: 自分のタイムラインから検索するワード。スペース区切りで複数指定可能。
* `FILTER_STREAM_WORDS`: Twitter全体から検索するワード。スペース区切りで複数指定可能。
* `MUTE_USERS`: エゴサ対象外にするユーザ。スペース区切りで複数指定可能。

## 普通に起動

```bash
$ gem install slack_twitter_egosa
$ cat > .env
WEBHOOK_URL=https://hooks.slack.com/services/XXXXXXXX/XXXXXXXX/XXXXXXXX
CONSUMER_KEY=XXXXXXXX
CONSUMER_SECRET=XXXXXXXX
OAUTH_TOKEN=XXXXXXXX
OAUTH_TOKEN_SECRET=XXXXXXXX
USER_STREAM_WORDS=阿部 あべ
FILTER_STREAM_WORDS=abcang ABCanG1015 -@ABCanG1015
MUTE_USERS=ABCanG1015
^D
$ slack_twitter_egosa .env
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
    -e "FILTER_STREAM_WORDS=abcang ABCanG1015 -@ABCanG1015" \
    -e "MUTE_USERS=ABCanG1015" \
    abcang/slack-twitter-egosa
```

## 更新履歴
* 2016/08/23: 公開
* 2016/09/20: ミュートユーザ、除外キーワード機能を追加
* 2016/09/22: 除外キーワードバグの修正、gemで公開、大文字小文字を区別しないようにした

## ライセンス
MIT
