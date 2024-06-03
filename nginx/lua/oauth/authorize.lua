local surrealdb = require('surrealdb')
local cjson = require("cjson")

if ngx.var[1] == 'github' then
  local response = surrealdb.fn("getOAuthUrl", ngx.var[1]);

	return ngx.redirect(response[1].result, 302)
else
  ngx.exit(ngx.HTTP_BAD_REQUEST)
end