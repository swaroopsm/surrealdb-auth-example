local surrealdb = require("surrealdb")
local cjson = require("cjson")

if ngx.var[1] == "github" or ngx.var[1] == "google" then
	local response = surrealdb.fn(ngx.var[1] .. "__oauthUrl")
	local data = cjson.decode(response.body)

	return ngx.redirect(data[1].result, 302)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
