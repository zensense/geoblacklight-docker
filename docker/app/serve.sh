#!/usr/bin/env bash
set -em

# primarily using this script to begin install of the Ruby app, 
# because the Docker container needs a new shell.

source ~/.profile

SOLR_VER=9.1.1
VIEW_COMPONENT_VERSION=2.6.6
RAILS_VERSION=6.1.4.6
RUBY_VER=3.2.1

ROOT_DIR="/geoblacklight"
APP_DIR="${ROOT_DIR}/ual_geoblacklight"
SOLR_DIR="${ROOT_DIR}/solr"
SOLR_HOME="${SOLR_DIR}/server/solr"
USER_HOME="/home/geoblacklight"
SCRIPTS_DIR="${USER_HOME}/docker/app"

if [[ ! -d "${APP_DIR}" ]]; then
    rvm install $RUBY_VER
    gem install bundler rails

    sudo chown geoblacklight:geoblacklight /home/geoblacklight/docker

    cd $ROOT_DIR
    rails new ual_geoblacklight -m https://raw.githubusercontent.com/geoblacklight/geoblacklight/main/template.rb

    cd $APP_DIR
    rm .solr_wrapper.yml && cp /home/geoblacklight/docker/app/.solr_wrapper.yml ./.solr_wrapper.yml
    rake geoblacklight:server["-p 3000 -b 0.0.0.0"]
else
    # restart both servers since we have apparently done this before
    # GOB server is too dumb to start with the same command as above
    cd $SOLR_DIR
    bin/solr start -h "0.0.0.0" -p 8983 -V

    cd $APP_DIR
    rm -rf tmp
    rails s -b "0.0.0.0" -p 3000
fi