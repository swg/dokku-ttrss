# dokku-ttrss

## Installation

Create the app and database container:

`dokku apps:create ttrss`

`dokku postgres:create ttrss-pgsql`

Configure the app for initial deployment:

`dokku config:set ttrss SELF_URL_PATH='http://ttrss.dokku.me'`

`dokku config:set ttrss WRITE_SCHEMA=true`

Deploy the app:

`git remote add dokku@dokku.me:ttrss`

`git push dokku master`

Unset WRITE_SCHEMA:

`dokku config:unset WRITE_SCHEMA`

## Configuration

All configuration is done with environment variables and setting them via Dokku.
They are documented in the [app.json](app.json).

## Plugins

Plugins with git repositories can be cloned with the config variable GIT_PLUGINS:
`dokku config:set ttrss GIT_PLUGINS='https://github.com/DigitalDJ/tinytinyrss-fever-plugin,fever;'`
`dokku config:set ttrss GIT_PLUGINS='https://github.com/ttplugin/example,example;https://github.com/ttplugin/eg_proj,another;'`

Unlike system plugins these are enabled in the web interface, not via the
config varable `PLUGINS`. See [fox/tt-rss/wiki/Plugins](https://git.tt-rss.org/fox/tt-rss/wiki/Plugins) for more info.

## Backing up

Dump the database:
`dokku postgresql:dump ttrss-database | gzip -9 > ttrss.gz".`

## Updating

Updating tt-rss is done through rebuilding.
If a schema update is required, run the following command:
`dokku run ttrss vendor/fox/ttrss/update.php --update-schema`
