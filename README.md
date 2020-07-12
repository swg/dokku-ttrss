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

`dokku config:set --no-restart ttrss GIT_PLUGINS='https://github.com/DigitalDJ/tinytinyrss-fever-plugin,fever;'`

`dokku config:set --no-restart ttrss GIT_PLUGINS='https://github.com/ttplugin/example,example;https://github.com/ttplugin/eg_proj,another;'`

Note: you will have to rebuild the container afterwards for these to work:

`dokku config:set --no-restart ttrss GIT_PLUGINS='https://repo.git/repo.git,repo'`

`dokku ps:rebuild ttrss`

Unlike system plugins these are enabled in the web interface, not via the
config varable `PLUGINS`.

See [fox/tt-rss/wiki/Plugins](https://git.tt-rss.org/fox/tt-rss/wiki/Plugins) for more info.

## Backing up

Dump the database: `dokku postgres:export ttrss-database | xz -9ev > ttrss-$(date +%Y%m%d-%H%M).xz`

## Updating

Updating tt-rss is done through rebuilding:

`dokku ps:rebuild ttrss`

If a schema update is required, run the following command:

`dokku run ttrss vendor/fox/ttrss/update.php --update-schema`

## ERROR: Failed to download minimal PHP for bootstrapping

This is usually caused by the buildpack/herokuish being outdated.

I recommend you update your dokku installation first and foremost,
but a quick fix can be achieved by manually setting the buildpack URL.

Find a recent buildpack version here: [https://github.com/heroku/heroku-buildpack-php/releases](https://github.com/heroku/heroku-buildpack-php/releases)

And substitute the ref at the end of this URL with the version you choose:

`dokku config:set ttrss BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-php.git#v${VERSION}`

`dokku ps:rebuild ttrss`

You can check the current version of your buildpack using `dokku report`:

`dokku report | grep heroku`

After upgrading your configuration, remember to unset the BUILDPACK_URL:

`dokku config:unset ttrss BUILDPACK_URL`
