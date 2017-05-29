# Ael

[![Build Status](https://travis-ci.org/Nebo15/ael.api.svg?branch=master)](https://travis-ci.org/Nebo15/ael.api) [![Coverage Status](https://coveralls.io/repos/github/Nebo15/ael.api/badge.svg)](https://coveralls.io/github/Nebo15/ael.api)

Ael is a media content storage access control system that allows to generate secrets
([Signed URL's](https://cloud.google.com/storage/docs/access-control/create-signed-urls-program))
on demand. Secrets have configured TTL and allow to perform required actions within specific bucket
subtree, that allows to have fine-grained control over media storage contents.

Clients can use secrets to directly access Google Cloud Storage or Amazon S3 via their API
([Google Cloud Storage API](https://cloud.google.com/storage/docs/xml-api/put-object-upload)), reducing
data delivery complexity, number places that have access to critical data and trafic costs for your project.

Cloud storage buckets can have most restricted access rights, being available only for cloud account owners.

## Installation

### Heroku One-click deployment

  [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/nebo15/ael.api)

### Docker

  Images are available on [nebo15/ael_api](https://hub.docker.com/r/nebo15/ael_api/) Docker Hub.

## Configuration

Documentation on environment configuration can be found in [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md).

## API Description

This project uses API Blueprint for REST API specs, you can find them in [apiary.apib](apiary.apib) file.
