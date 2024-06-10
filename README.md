# surrealdb-auth-example

An example app demonstrating authentication using surrealdb.

![A screenshot showing various screens of the app](./screenshot.png "surrealdb auth screenshot")

##### Tech stack:

- [SurrealDB](https://surrealdb.com/)
- [Openresty](https://openresty.org/) / [lua-nginx-module](https://github.com/openresty/lua-nginx-module)
- [Remix](https://remix.run/)

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
