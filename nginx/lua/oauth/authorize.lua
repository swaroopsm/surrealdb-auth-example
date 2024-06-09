local ck = require("resty.cookie")
local surrealdb = require("surrealdb")
local cjson = require("cjson")
local cookie = ck:new()

if ngx.var[1] == "github" or ngx.var[1] == "google" then
	local response = surrealdb.fn(ngx.var[1] .. "__oauthUrl")

	if response.status == 200 then
		local data = cjson.decode(response.body)
		local data = cjson.decode(response.body)
		return ngx.redirect(data[1].result, 302)
	else
		-- Check if authToken exists and is invalid
		-- Then we reset the cookie and try to hit this route again
		local authToken = cookie:get("__auth_token")

		if authToken then
			cookie:set({
				key = "__auth_token",
				value = "",
				path = "/",
			})

			-- TODO: Don't hardcode FE URL here
			ngx.redirect(os.getenv("FRONTEND_URL") .. "/api/oauth/" .. ngx.var[1], 302)
		end

		ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
	end
else
	ngx.exit(ngx.HTTP_BAD_REQUEST)
end
