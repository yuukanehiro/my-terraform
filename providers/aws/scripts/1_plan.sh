#!/usr/bin/env bash

# 未定義変数、エラーで処理を止める
set -eu

# 格納されているディレクトリからステージ名取得 ex. develop|staging|production
CURRENT=$(cd $(dirname $0);pwd)
ENV=`echo "$CURRENT" | sed -e 's/.*\/\([^\/]*\)$/\1/'`


echo "Start Directry Check"
if [ $ENV = "develop" ] || [ $ENV = "staging" ] || [ $ENV = "production" ]; then
    echo "environments/${ENV}"
    echo "Directry Check: true"
else
    echo "Error: Directry Check: false"
    exit 1
fi
echo "End Directry Check"

echo "Start terraform init"
terraform init -var=aws_profile="terraform-local-deployer"
echo "End terraform init"

echo "Start terraform validate"
terraform validate
terraform fmt
echo "End terraform validate"

echo "Start terraform plan"
# ファイル出力
mkdir -p ./logs
terraform plan -var=aws_profile="terraform-local-deployer" -no-color | tee -a ./logs/`date "+%Y%m%d_%H%M%S"`_plan.log
# 標準出力
terraform plan -var=aws_profile="terraform-local-deployer"
echo "End terraform plan"
