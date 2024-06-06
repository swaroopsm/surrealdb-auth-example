# surrealdb-auth-example

An example demonstrating authentication using surrealdb as the db and openresty / lua as a router

## Getting started

- Make sure you have `docker` installed
- Rename `surrealdb/config.sample.surql` to `surrealdb/config.surql` and adjust the values appropriately
- Run `docker compose up --build -d`
- Run `make import` to import the surrealdb schema and functions

## Authenticate as a GitHub user

- Visit: `http://localhost:8080/oauth/github`
