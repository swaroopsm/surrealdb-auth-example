local surrealdb = require("surrealdb")
local cjson = require("cjson")

if ngx.var[1] == "github" then
	local response = surrealdb.fn("github__oauthUrl")
	local data = cjson.decode(response.body)

	return ngx.redirect(data[1].result, 302)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
