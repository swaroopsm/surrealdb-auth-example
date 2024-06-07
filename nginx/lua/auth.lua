local ck = require("resty.cookie")
local cjson = require("cjson")

local actionName = ngx.var[1]

local login = function() end

local signup = function() end

local logout = function()
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
	login = login,
	signup = signup,
	logout = logout,
}

if actions[actionName] then
	return actions[actionName]()
else
	ngx.exit(ngx.HTTP_NOT_FOUND)
end
