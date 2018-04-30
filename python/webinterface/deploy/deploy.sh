#!/bin/bash
ROOT_DIR=${PWD}
GIT_DIR="${PWD}/HEDTools"
IMAGE_NAME="hedtools-validation:latest"
CONTAINER_NAME="hedtools-validation"
GIT_REPO_URL="https://github.com/VisLab/HEDTools"
GIT_REPO_BRANCH="master"
HOST_PORT=33000;
CONTAINER_PORT=80;
DEPLOY_DIR="HEDTools/python/webinterface/deploy"
CODE_DEPLOY_DIR="${DEPLOY_DIR}/hedtools"
CONFIG_FILE="${ROOT_DIR}/config.py"
WSGI_FILE="${DEPLOY_DIR}/webinterface.wsgi"
WEBINTERFACE_CODE_DIR="HEDTools/python/webinterface/webinterface/"
VALIDATOR_CODE_DIR="HEDTools/python/hedvalidation/hedvalidation/"
git clone $GIT_REPO_URL -b $GIT_REPO_BRANCH
mkdir $CODE_DEPLOY_DIR
cp $CONFIG_FILE $CODE_DEPLOY_DIR
cp $WSGI_FILE $CODE_DEPLOY_DIR
cp -r $WEBINTERFACE_CODE_DIR $CODE_DEPLOY_DIR
cp -r $VALIDATOR_CODE_DIR $CODE_DEPLOY_DIR
cd $DEPLOY_DIR
echo Building new containing...
docker build -t $IMAGE_NAME .
echo Deleting old container...
docker rm -f $CONTAINER_NAME
docker run --restart=always --name $CONTAINER_NAME -d -p $HOST_PORT:$CONTAINER_PORT $IMAGE_NAME
rm -rf $GIT_DIR
