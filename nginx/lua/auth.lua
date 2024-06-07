local ck = require("resty.cookie")

local actionName = ngx.var[1]

local login = function() end

local signup = function() end

local logout = function()
	local cookie = ck:new()

	cookie:set({
		key = "__auth_token",
		value = "gg",
	})

	ngx.exit(ngx.HTTP_NO_CONTENT)
end

local actions = {
	login = login,
	signup = signup,
	logout = logout,
}

if actions[actionName] then
	return actions[actionName]()
else
	ngx.exit(ngx.HTTP_NOT_FOUND)
end
