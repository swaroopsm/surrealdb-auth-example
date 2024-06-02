package.path = "/etc/nginx/conf.d/lua/?.lua;" .. package.path

local cjson = require("cjson")
local jwt = require("resty.jwt")
local greeting = require("greeting")
local httpc = require("resty.http").new()

local user = {
	name = "Striker Sethumadhavan",
	email = "striker@example.org",
}

local routes = {}

local invoke_surrealdb_func = function(fn, token)
	local headers = {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["NS"] = "surrealdb",
		["DB"] = "public",
	}

	if token then
		headers["Authorization"] = "Bearer " .. token
	end
	local res, err = httpc:request_uri("http://surrealdb:8000", {
		method = "POST",
		path = "/sql",
		body = fn,
		headers = headers,
	})

	ngx.log(ngx.INFO, fn)
	ngx.log(ngx.INFO, res.body)

	return pcall(cjson.decode, res.body)
end

local createOrFindUser = function(payload)
	local res, err = httpc:request_uri("http://surrealdb:8000", {
		method = "POST",
		path = "/signin",
		body = cjson.encode({
			ns = "surrealdb",
			db = "public",
			user = "db",
			pass = "password",
		}),
		headers = {
			["Content-Type"] = "application/json",
			["Accept"] = "application/json",
		},
	})

	if not res then
		ngx.log(ngx.ERR, "request failed: ", err)
		return
	end

	ngx.log(ngx.INFO, res.body)

	if res then
		local status, data = pcall(cjson.decode, res.body)
		return invoke_surrealdb_func(
			'fn::mayBeCreateUserAfterOAuth("' .. payload.name .. '","' .. payload.email .. '")',
			data.token
		)
	end
	-- end
end

routes["/me"] = function()
	local status, response = invoke_surrealdb_func("fn::whoami()", nil)

	if status then
		if response[1].status == "ERR" then
			local err = { error = "unauthorized" }
			ngx.status = 401
			ngx.say(cjson.encode(err))
			ngx.exit(ngx.HTTP_UNAUTHORIZED)

			-- ngx.redirect("/401")
		else
			ngx.say(cjson.encode(response[1].result))
			ngx.exit(ngx.HTTP_OK)
		end
	end
end

routes["/ping"] = function()
	ngx.say("pong")
	ngx.exit(200)
end

routes["/oauth/github"] = function()
	local status, response = invoke_surrealdb_func("fn::generateGithuOAuthUrl()", nil)

	if status then
		return ngx.redirect(response[1].result, 302)
	end
end

routes["/oauth/github/callback"] = function()
	local params = ngx.req.get_uri_args()
	local fn = "fn::authorizeGithub(" .. '"' .. params["code"] .. '"' .. ")"

	local status, response = invoke_surrealdb_func(fn, nil)

	if status then
		if response[1].result.id then
			local current_date = os.date("*t")
			local current_timestamp = os.time(current_date)
			local seven_day_seconds = 24 * 7 * 60 * 60
			local exp = current_timestamp + seven_day_seconds

			-- get user
			local status2, me = createOrFindUser({
				name = response[1].result.name,
				email = response[1].result.email,
			})

			ngx.log(ngx.INFO, cjson.encode(me))

			if me then
				local jwt_token = jwt:sign("my_gh_token", {
					header = { typ = "JWT", alg = "HS256" },
					payload = {
						id = me[1.].result.id,
						tk = "github",
						sc = "user",
						db = "public",
						ns = "surrealdb",
						exp = exp,
					},
				})

				ngx.say(cjson.encode({
					jwt_token = jwt_token,
				}))
				ngx.exit(ngx.HTTP_OK)
			end
		else
			ngx.status = 401
			ngx.say("unauthorized")
			ngx.exit(ngx.HTTP_UNAUTHORIZED)
		end
	end
end

local get_route = function()
	local request_path = ngx.var.uri

	if not routes[request_path] then
		return error("no_route")
	end

	return routes[request_path]()
end

local success, response = pcall(function()
	return get_route()
end)

if success then
	return ngx.say(response)
else
	return ngx.exit(ngx.HTTP_NOT_FOUND)
end

-- ngx.say(cjson.encode(user))
