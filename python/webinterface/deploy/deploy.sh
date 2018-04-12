#!/bin/bash
BUILD_TAG_NAME = "hedtools-validation:latest"
GIT_REPO_URL = "https://github.com/VisLab/HEDTools"
GIT_REPO_BRANCH = "develop"
HOST_PORT = 5000;
CONTAINER_PORT = 80;
DEPLOY_DIR = "HEDTools/python/webinterface/deploy/"
CODE_DEPLOY_DIR = $DEPLOY_DIR + "hedtools"
CONFIG_FILE = $DEPLOYDIR + "config.py"
WEBINTERFACE_CODE_DIR = "HEDTools/python/webinterface/webinterface/"
VALIDATOR_CODE_DIR = "HEDTools/python/hedvalidation/hedvalidation/"
git clone $GIT_REPO_URL -b $GIT_REPO_BRANCH
cd $DEPLOY_DIR
mkdir $CODE_DEPLOY_DIR
cp $CONFIG_FILE $CODE_DEPLOY_DIR
cp $WEBINTERFACE_CODE_DIR $CODE_DEPLOY_DIR
cp $VALIDATOR_CODE_DIR $CODE_DEPLOY_DIR
docker build -t $BUILD_TAG_NAME
docker run --restart=always -d -p $HOST_PORT:$CONTAINER_PORT $BUILD_TAG_NAME
rm -r HEDTools
