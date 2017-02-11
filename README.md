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

