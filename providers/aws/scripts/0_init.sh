!/usr/bin/env bash

cd `dirname $0`

# 未定義変数、エラーで処理を止める
set -eu

# 共通ファイルで実行できるようにリンク作成
cd ../environments/develop/
ln -s ../../scripts/1_plan.sh 1_plan.sh
ln -s ../../scripts/2_apply.sh 2_apply.sh
cd ../staging
ln -s ../../scripts/1_plan.sh 1_plan.sh
ln -s ../../scripts/2_apply.sh 2_apply.sh
cd ../production
ln -s ../../scripts/1_plan.sh 1_plan.sh
ln -s ../../scripts/2_apply.sh 2_apply.sh

# AWS Cli ローカル実行用AMIユーザのプロフィール設定
aws configure --profile terraform-local-deployer
