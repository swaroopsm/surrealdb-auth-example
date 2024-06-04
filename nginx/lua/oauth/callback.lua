local cjson = require("cjson")
local surrealdb = require("surrealdb")
local params = ngx.req.get_uri_args()

if ngx.var[1] == "github" then
	local response = surrealdb.fn("authorizeGithub", params.code)

	ngx.log(ngx.INFO, cjson.encode(response))

	local result = response[1].result

	local user = surrealdb.signup({
		name = result.name,
		email = result.email,
		sub = result.id,
		provider = ngx.var[1],
		type = "oauth",
	})

	ngx.say(cjson.encode(user))

	ngx.exit(ngx.HTTP_OK)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
