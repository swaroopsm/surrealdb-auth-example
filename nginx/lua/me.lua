local surrealdb = require("surrealdb")
local cjson = require("cjson")

local response = surrealdb.fn("whoami")
local data = cjson.decode(response.body)
ngx.log(ngx.INFO, data[1].status)

if data[1].status == "ERR" then
	return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

ngx.say(cjson.encode(data[1].result))
ngx.exit(ngx.OK)
