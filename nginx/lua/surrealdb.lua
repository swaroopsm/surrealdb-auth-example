local _M = {}

local httpc = require("resty.http").new()
local cjson = require("cjson")

local SURREALDB_ENDPOINT = "http://surrealdb:8000"
local SURREALDB_NS = os.getenv("SURREALDB_NS")
local SURREALDB_DB = os.getenv("SURREALDB_DB")

local getHeaders = function()
	local headers = {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["NS"] = SURREALDB_NS,
		["DB"] = SURREALDB_DB,
	}

	local token = ngx.req.get_headers()["Authorization"]
	local authCookieName = "cookie_" .. "__auth_token"
	local authToken = ngx.var[authCookieName]

	if token then
		headers["Authorization"] = token
	elseif authToken then
		headers["Authorization"] = "Bearer " .. authToken
	end

	return headers
end

_M.getVersion = function()
	local res, err = httpc:request_uri(SURREALDB_ENDPOINT, {
		method = "GET",
		path = "/version",
	})

	if err then
		error("surrealdb http error")
	end

	return res.body
end

_M.sql = function(statement, token)
	local headers = getHeaders()

	if token then
		headers["Authorization"] = "Bearer " .. token
	end

	local res, err = httpc:request_uri(SURREALDB_ENDPOINT, {
		method = "POST",
		path = "/sql",
		body = statement,
		headers = headers,
	})

	if err then
		ngx.log(ngx.ERROR, err)
	end

	return res
	-- return cjson.decode({
	--   data = res
	-- })
end

_M.fn = function(fn, ...)
	local args = { ... }
	local expression = "fn::" .. fn .. "("

	if args then
		for i, v in ipairs(args) do
			if type(v == "string") then
				expression = expression .. '"' .. v .. '"'
			elseif type(v == "number") then
				expression = expression .. v
			else
			end

			if i ~= #args then
				expression = expression .. ","
			end
		end
	end

	expression = expression .. ")"

	return _M.sql(expression)
end

_M.signup = function(params)
	local body = {
		["NS"] = SURREALDB_NS,
		["DB"] = SURREALDB_DB,
	}

	if params.type == "oauth" then
		body["SC"] = "oauth"
		body["email"] = params.email
		body["name"] = params.name
		body["provider"] = params.provider
		body["sub"] = tostring(params.sub)
		body["meta"] = params.meta
	else
		body["email"] = params.email
		body["name"] = params.name
		body["password"] = params.password
		body["SC"] = "credentials"
	end

	local res, err = httpc:request_uri(SURREALDB_ENDPOINT, {
		method = "POST",
		path = "/signup",
		body = cjson.encode(body),
		headers = {
			["Content-Type"] = "application/json",
			["Accept"] = "application/json",
		},
	})

	if err then
		error("surrealdb http error")
	end

	return res
end

_M.signin = function(params)
	local body = {
		["NS"] = SURREALDB_NS,
		["DB"] = SURREALDB_DB,
		["SC"] = "credentials",
		["email"] = params.email,
		["password"] = params.password,
	}

	local res, err = httpc:request_uri(SURREALDB_ENDPOINT, {
		method = "POST",
		path = "/signin",
		body = cjson.encode(body),
		headers = {
			["Content-Type"] = "application/json",
			["Accept"] = "application/json",
		},
	})

	if err then
		error("surrealdb http error")
	end

	return res
end

return _M
