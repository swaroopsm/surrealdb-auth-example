local _M = {}

local httpc = require("resty.http").new()
local cjson = require("cjson")

local SURREALDB_ENDPOINT = "http://surrealdb:8000"
local SURREALDB_NS = os.getenv("SURREALDB_NS")
local SURREALDB_DB = os.getenv("SURREALDB_DB")
local SURREALDB_USER = os.getenv("SURREALDB_DATABASE_USER")
local SURREALDB_PASSWORD = os.getenv("SURREALDB_DATABASE_PASSWORD")

local getHeaders = function()
	return {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["NS"] = SURREALDB_NS,
		["DB"] = SURREALDB_DB,
	}
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
		body = "fn::generateGitHubOAuthUrl()",
		headers = headers,
	})

	ngx.log(ngx.INFO, statement)

	return cjson.decode(res.body)
end

_M.fn = function(fn, ...)
	local args = { ... }
	local expression = "fn::" .. fn .. "("

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

	expression = expression .. ")"

	return _M.sql(expression)
end

_M.signup = function(params)
	local body = {
		["NS"] = SURREALDB_NS,
		["DB"] = SURREALDB_DB,
	}

	if params.type == "oauth" then
		body["email"] = params.email
		body["name"] = params.name
		body["provider"] = params.provider
		body["sub"] = params.sub
	end

	local res, err = httpc:request_uri(SURREALDB_ENDPOINT, {
		method = "POST",
		path = "/signup",
		body = cjson.encode(body),
		headers = getHeaders(),
	})

	if err then
		error("surrealdb http error")
	end

	return res.body
end

_M.signin = function(params)
	local body = {
		["NS"] = SURREALDB_NS,
		["DB"] = SURREALDB_DB,
	}

	if params.type == "oauth" then
		body["email"] = params.email
		body["provider"] = params.provider
		body["sub"] = params.sub
	end

	local res, err = httpc:request_uri(SURREALDB_ENDPOINT, {
		method = "POST",
		path = "/signin",
		body = cjson.encode(body),
		headers = getHeaders(),
	})

	if err then
		error("surrealdb http error")
	end

	return res.body
end

return _M
