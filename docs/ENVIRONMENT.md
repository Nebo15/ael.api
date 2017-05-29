# Environment Variables

This environment variables can be used to configure released docker container at start time.
Also sample `.env` can be used as payload for `docker run` cli.

## General

| VAR_NAME      | Default Value           | Description |
| ------------- | ----------------------- | ----------- |
| ERLANG_COOKIE | `03/yHifHIEl`.. | Erlang [distribution cookie](http://erlang.org/doc/reference_manual/distributed.html). **Make sure that default value is changed in production.** |
| LOG_LEVEL     | `info` | Elixir Logger severity level. Possible values: `debug`, `info`, `warn`, `error`. |

## Phoenix HTTP Endpoint

| VAR_NAME      | Default Value | Description |
| ------------- | ------------- | ----------- |
| PORT          | `4000`        | HTTP host for web app to listen on. |
| HOST          | `localhost`   | HTTP port for web app to listen on. |
| SECRET_KEY    | `b9WHCgR5TGcr`.. | Phoenix [`:secret_key_base`](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html). **Make sure that default value is changed in production.** |

## Ael

| VAR_NAME                 | Default Value | Description |
| ------------------------ | ------------- | ----------- |
| KNOWN_BUCKETS            | []            | Available buckets for creating a signed URL. |
| SECRETS_TTL              | `600`         | Living time for a signed url. |
| SERVICE_ACCOUNT_KEY_PATH | `priv/service_account_key.json` | File path to account secret key |
