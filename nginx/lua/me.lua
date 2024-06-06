local surrealdb = require("surrealdb")
local cjson = require("cjson")

local cookieName = "cookie_" .. "__auth_token"

local authToken = ngx.var[cookieName]

-- Probably this should be part of a middleware
if authToken then
	ngx.req.set_header("Authorization", "Bearer " .. authToken)
end

local response = surrealdb.fn("whoami")

if response.status == ngx.HTTP_OK then
	local data = cjson.decode(response.body)
	ngx.log(ngx.INFO, data[1].status)

	if data[1].status == "ERR" then
		return ngx.exit(ngx.HTTP_UNAUTHORIZED)
	end

	ngx.say(cjson.encode(data[1].result))
	ngx.exit(ngx.OK)
else
	ngx.exit(response.status)
end
