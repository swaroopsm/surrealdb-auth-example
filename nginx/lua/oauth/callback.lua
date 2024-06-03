local cjson = require("cjson")
local surrealdb = require("surrealdb")
local params = ngx.req.get_uri_args()

if ngx.var[1] == "github" then
	local response = surrealdb.fn("authorizeGithub", params.code)

	ngx.say(cjson.encode(response))
	ngx.exit(ngx.HTTP_OK)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
