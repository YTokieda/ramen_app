#!/usr/bin/env bash
# Render のビルド用スクリプト（Build Command: bin/render-build.sh）
# 注意：db:migrate:reset / db:reset / db:seed は本番データを消す・上書きするので絶対に入れない
set -o errexit

# erb と cgi の依存関係の衝突を回避（Ruby 更新までの暫定対応）
gem install cgi -v 0.5.2 --no-document
RUBYOPT="-rcgi" bundle install

bundle exec rails assets:precompile
bundle exec rails assets:clean

# 未適用のマイグレーションだけを実行する（既存データは消えない）
bundle exec rails db:migrate

# 審査から90日たった店舗オーナーの営業許可証を削除する
bundle exec rails shop_owners:purge_expired_licenses

# ADMIN_EMAILS に書かれた登録済みユーザーを管理者にする（未設定なら何もしない）
bundle exec rails admin:grant_from_env
