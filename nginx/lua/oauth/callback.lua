local cjson = require("cjson")
local surrealdb = require("surrealdb")
local params = ngx.req.get_uri_args()

if ngx.var[1] == "github" then
	local response = surrealdb.fn("github__oauthAuthorize", params.code)
	local data = cjson.decode(response.body)

	ngx.log(ngx.INFO, response.body)

	local result = data[1].result
	local params = {
		name = result.name,
		email = result.email,
		sub = result.id,
		meta = result.meta,
		provider = ngx.var[1],
		type = "oauth",
	}

	ngx.log(ngx.INFO, cjson.encode(params))

	local user = surrealdb.signup(params)

	ngx.say(cjson.encode(user))

	ngx.exit(ngx.HTTP_OK)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
