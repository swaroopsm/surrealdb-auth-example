local cjson = require("cjson")
local surrealdb = require("surrealdb")
local params = ngx.req.get_uri_args()

if ngx.var[1] == "github" then
	local response = surrealdb.fn("authorizeGithub", params.code)

	ngx.log(ngx.INFO, cjson.encode(response))

	local user = surrealdb.signup({
		name = response.name,
		email = response.email,
		sub = response.id,
		provider = ngx.var[1],
	})

	ngx.say(cjson.encode(user))

	ngx.exit(ngx.HTTP_OK)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
