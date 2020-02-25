#!/bin/bash

declare -A TTRSS
DATABASE_REGEX="([^:]+)://([^:]+):([^@]+)@([^:]+):([0-9]+)/(.*)"
CONFIG_VERSION="26"
GIT_PLUGINS_ENABLED=$(awk -F ";" '{print NF-1}' <<< "${GIT_PLUGINS}")

check_database_url()
{
  if [[ $DATABASE_URL =~ $DATABASE_REGEX ]]; then
    DB_TYPE=${BASH_REMATCH[1]}
    DB_USER=${BASH_REMATCH[2]}
    DB_PASS=${BASH_REMATCH[3]}
    DB_HOST=${BASH_REMATCH[4]}
    DB_PORT=${BASH_REMATCH[5]}
    DB_NAME=${BASH_REMATCH[6]}
  else
    printf "[error] Database not linked to Tiny Tiny RSS container\n"
    exit 1
  fi
}

populate_settings()
{
  if [[ $DB_TYPE == "postgres" ]]; then
    DB_TYPE="pgsql"
  fi

  TTRSS[DB_TYPE]=$DB_TYPE
  TTRSS[DB_HOST]=$DB_HOST
  TTRSS[DB_USER]=$DB_USER
  TTRSS[DB_NAME]=$DB_NAME
  TTRSS[DB_PASS]=$DB_PASS
  TTRSS[DB_PORT]=$DB_PORT
  TTRSS[MYSQL_CHARSET]=${MYSQL_CHARSET:-UTF8}
  TTRSS[SELF_URL_PATH]=${SELF_URL_PATH:-http://example.org/tt-rss/}
  TTRSS[FEED_CRYPT_KEY]=$FEED_CRYPT_KEY
  TTRSS[SINGLE_USER_MODE]=${SINGLE_USER_MODE:-false}
  TTRSS[SIMPLE_UPDATE_MODE]=${SIMPLE_UPDATE_MODE:-false}
  TTRSS[PHP_EXECUTABLE]=${PHP_EXECUTABLE:-/app/.heroku/php/bin/php}
  TTRSS[LOCK_DIRECTORY]=${LOCK_DIRECTORY:-lock}
  TTRSS[CACHE_DIR]=${CACHE_DIR:-cache}
  TTRSS[ICONS_DIR]=${ICONS_DIR:-feed-icons}
  TTRSS[ICONS_URL]=${ICONS_URL:-feed-icons}
  TTRSS[AUTH_AUTO_CREATE]=${AUTH_AUTO_CREATE:-true}
  TTRSS[AUTH_AUTO_LOGIN]=${AUTH_AUTO_LOGIN:-true}
  TTRSS[FORCE_ARTICLE_PURGE]=${AUTH_AUTO_LOGIN:-0}
  TTRSS[PUBSUBHUBBUB_HUB]=${PUBSUBHUBBUB_HUB:-}
  TTRSS[PUBSUBHUBBUB_ENABLED]=${PUBSUBHUBBUB_ENABLED:-false}
  TTRSS[SPHINX_SERVER]=${SPHINX_SERVER:-localhost:9312}
  TTRSS[SPHINX_INDEX]=${SPHINX_INDEX:-ttrss, delta}
  TTRSS[ENABLE_REGISTRATION]=${ENABLE_REGISTRATION:-false}
  TTRSS[REG_NOTIFY_ADDRESS]=$REG_NOTIFY_ADDRESS
  TTRSS[REG_MAX_USERS]=${REG_MAX_USERS:-10}
  TTRSS[SESSION_COOKIE_LIFETIME]=${SESSION_COOKIE_LIFETIME:-86400}
  TTRSS[SMTP_FROM_NAME]=${SMTP_FROM_NAME:-Tiny Tiny RSS}
  TTRSS[SMTP_FROM_ADDRESS]=${SMTP_FROM_ADDRESS:-noreply@your.domain.dom}
  TTRSS[DIGEST_SUBJECT]=${DIGEST_SUBJECT:-[tt-rss] 24 hour digest}
  TTRSS[SMTP_SERVER]=$SMTP_SERVER
  TTRSS[SMTP_LOGIN]=$SMTP_LOGIN
  TTRSS[SMTP_PASSWORD]=$SMTP_PASSWORD
  TTRSS[SMTP_SECURE]=${SMTP_SECURE:-tls}
  TTRSS[CHECK_FOR_UPDATES]=${CHECK_FOR_UPDATES:-true}
  TTRSS[ENABLE_GZIP_OUTPUT]=${ENABLE_GZIP_OUTPUT:-false}
  TTRSS[PLUGINS]=${PLUGINS:-auth_internal, note}
  TTRSS[LOG_DESTINATION]=${LOG_DESTINATION:-sql}
}

write_config()
{
  if ! grep -q "define('CONFIG_VERSION', $CONFIG_VERSION);" vendor/fox/ttrss/config.php-dist; then
    printf "[warning] Tiny Tiny RSS config version doesn't match\n"
  fi

  cp vendor/fox/ttrss/config.php-dist vendor/fox/ttrss/config.php

  for K in "${!TTRSS[@]}";
  do
    sed -i "s#\(define('$K', ['\"]\?\)\([^'\"]*\)\(['\"]\?);\)#\1${TTRSS[$K]}\3#" vendor/fox/ttrss/config.php
  done
}

write_schema()
{
  printf "[info] Writing Tiny Tiny RSS schema...\n"
  PGPASSWORD=$DB_PASS psql -h  $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME -f vendor/fox/ttrss/schema/ttrss_schema_pgsql.sql
}

clone_plugin()
{
  local src name

  IFS="," read src name <<< "$1"

  if [[ ! "$src" || ! "$name" ]]; then
    printf "[error] Invalid seperator on plugin: $1\n"
  else
    local dir="vendor/fox/ttrss/plugins.local/$name"

    if [ ! -d "$directory/.git" ]; then
      printf "[info] Cloning $src to $dir\n"
      git clone $src $dir
    else
      printf "[info] Removing $dir for sanity and cloning $src to $dir\n"
      rm -rf $dir
      git clone $src $dir
    fi

  fi
}

check_database_url

populate_settings

write_config

if [ $GIT_PLUGINS_ENABLED -gt 0 ]; then
  for i in $(seq 1 $GIT_PLUGINS_ENABLED); do
    clone_plugin $(echo $GIT_PLUGINS | cut -d ";" -f $i)
  done
fi

if [[ $WRITE_SCHEMA ]] ; then
  write_schema
fi
