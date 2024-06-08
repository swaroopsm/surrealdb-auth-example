local ck = require("resty.cookie")
local cjson = require("cjson")
local surrealdb = require("surrealdb")

local actionName = ngx.var[1]

local signin = function()
	ngx.req.read_body()
	local body = cjson.decode(ngx.req.get_body_data())

	local response, err = surrealdb.signin({
		name = body.name,
		email = body.email,
		password = body.password,
	})

	if err then
		error(err)
	end

	if response.status ~= 200 then
		ngx.log(ngx.ERR, response.body)

		ngx.status = response.status
		ngx.say(cjson.encode({
			code = "err:signin",
			message = "Signin failed",
		}))
		ngx.exit(ngx.HTTP_BAD_REQUEST)
	end

	local result = cjson.decode(response.body)
	local cookie = ck:new()

	cookie:set({
		key = "__auth_token",
		value = result.token,
		path = "/",
		httponly = true,
	})

	ngx.say(cjson.encode({ success = true }))
	ngx.exit(ngx.HTTP_OK)
end

local signup = function()
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

	if response.status ~= 200 then
		ngx.log(ngx.ERR, response.body)

		ngx.status = response.status
		ngx.say(cjson.encode({
			code = "err:signup",
			message = "Signup failed",
		}))
		ngx.exit(ngx.HTTP_BAD_REQUEST)
	end

	local result = cjson.decode(response.body)
	local cookie = ck:new()

	cookie:set({
		key = "__auth_token",
		value = result.token,
		path = "/",
		httponly = true,
	})

	ngx.say(cjson.encode({ success = true }))
	ngx.exit(ngx.HTTP_OK)
end

local signout = function()
	local cookie = ck:new()
	local cookieFields, err = cookie:get_all()

	for key, value in pairs(cookieFields) do
		if key == "__auth_token" then
			cookie:set({
				key = "__auth_token",
				value = "",
				path = "/",
			})
		end
	end

	ngx.exit(ngx.HTTP_OK)
end

local actions = {
	signin = signin,
	signup = signup,
	logout = signout,
}

if actions[actionName] then
	return actions[actionName]()
else
	ngx.exit(ngx.HTTP_NOT_FOUND)
end
