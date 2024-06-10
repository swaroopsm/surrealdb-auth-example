local cjson = require("cjson")
local surrealdb = require("surrealdb")
local ck = require("resty.cookie")

local args = ngx.req.get_uri_args()

if ngx.var[1] == "github" or ngx.var[1] == "google" then
	local response = surrealdb.fn(ngx.var[1] .. "__oauthAuthorize", args.code)
	local data = cjson.decode(response.body)

	local result = data[1].result

	if data[1].status == "ERR" then
		ngx.log(ngx.ERR, response.body)
		ngx.status = response.status

		ngx.exit(ngx.HTTP_BAD_REQUEST)
	end

	local params = {
		name = result.name,
		email = result.email,
		sub = result.id,
		meta = result.meta,
		provider = ngx.var[1],
		type = "oauth",
	}

	local signupResponse = surrealdb.signup(params)
	local signupResult = cjson.decode(signupResponse.body)

	-- -- Set cookie and redirect to the FE App
	local cookie = ck:new()
	cookie:set({
		key = "__auth_token",
		value = signupResult.token,
		path = "/",
		httponly = true,
	})
	ngx.redirect(os.getenv("FRONTEND_URL") .. "", 302)
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
