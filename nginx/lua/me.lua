local surrealdb = require("surrealdb")
local cjson = require("cjson")

local response = surrealdb.fn("whoami")

if response.status == ngx.HTTP_OK then
	local data = cjson.decode(response.body)

	if data[1].status == "ERR" then
		return ngx.exit(ngx.HTTP_UNAUTHORIZED)
	end

	ngx.say(cjson.encode(data[1].result))
	ngx.exit(ngx.HTTP_OK)
else
	ngx.exit(response.status)
end
