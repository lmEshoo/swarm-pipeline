#!/bin/bash
source configure.sh
source pem

export MAIN_PATH=$PWD;
echo $MAIN_PATH;
GITHUB_ORGANIZATION_NAME="$1";
REPO_NAME="$2";

git clone https://github.com/$GITHUB_ORGANIZATION_NAME/$REPO_NAME.git \
|| git pull; echo "repo exists"

cd $REPO_NAME \
  && docker build -t lmestar/$REPO_NAME . \
  && docker push lmestar/$REPO_NAME \
  && cd $MAIN_PATH \
  && sudo bash swarm-app-start.sh up lmestar/$REPO_NAME app

rm -Rf $MAIN_PATH/$REPO_NAME
