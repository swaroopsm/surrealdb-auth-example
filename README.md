# surrealdb-auth-example

An example demonstrating authentication using surrealdb as the db and openresty / lua as a router

## Getting started

### Backend

- Make sure you have `docker` installed
- Rename `surrealdb/config.sample.surql` to `surrealdb/config.surql` and adjust the values appropriately
- Run `docker compose up --build -d`
- Run `make import` to import the surrealdb schema and functions

### Frontend

- `cd frontend`
- `npm i`
- `npm run dev`
- Visit: `http://localhost:5173`

## SurrealDB Functions:

| Name                         |                                      Description                                       |
| ---------------------------- | :------------------------------------------------------------------------------------: |
| `fn::github__oauthUrl`       |   Get oauth url for github that can be used to redirect the user the consent screen    |
| `fn::github__oauthAuthorize` | Exchange the auth code for an access token and return the user info of the Github user |
| `fn::google__oauthUrl`       |   Get oauth url for github that can be used to redirect the user the consent screen    |
| `fn::google__oauthAuthorize` | Exchange the auth code for an access token and return the user info of the Github user |
| `fn::whoami`                 |                      Returns basic info of the authenticated user                      |
