local cjson = require("cjson")
local surrealdb = require("surrealdb")
local args = ngx.req.get_uri_args()

if ngx.var[1] == "github" or ngx.var[1] == "google" then
	local response = surrealdb.fn(ngx.var[1] .. "__oauthAuthorize", args.code)
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

	local signupResponse = surrealdb.signup(params)
	local signupResult = cjson.decode(signupResponse.body)

	-- -- Set cookie and redirect to the FE App
	ngx.header["Set-Cookie"] = "__auth_token=" .. signupResult.token .. "; Path=/; SameSite=Strict; HttpOnly;"
	ngx.redirect("http://localhost:5173")
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
