local cjson = require("cjson")
local surrealdb = require("surrealdb")

ngx.req.read_body()
local body = cjson.decode(ngx.req.get_body_data())

local response, err = surrealdb.signup({
	name = body.name,
	email = body.email,
	password = body.password,
})

if err then
	error(err)
end

ngx.log(ngx.INFO, response.status)

if response.status == ngx.HTTP_OK then
	ngx.say(response.body)
	ngx.exit(ngx.HTTP_OK)
else
	ngx.status = response.status
	ngx.say(cjson.encode({
		code = "err:signup",
		message = "Signup failed",
	}))
	ngx.exit(response.status)
end

-- for key, val in pairs(args) do
-- 	if type(val) == "table" then
-- 		ngx.say(key, ": ", table.concat(val, ", "))
-- 	else
-- 		ngx.say(key, ": ", val)
-- 	end
-- end
