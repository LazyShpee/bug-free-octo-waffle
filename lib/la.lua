local la = {}
local cfg = {replaceScope = "@rep", strictReplace = false, strictRestore = false}

la.table = {}
la.string = {}
la.variable = {}

-- ###############################################################
-- # Strings functions
-- ###############################################################

function la.string.split(s, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	s:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

-- ###############################################################
-- # Tables functions
-- ###############################################################

function la.table.match(t1, t2, comp) -- Matches t1 values with t2 or t2 values using comp
	comp = comp or (function (a, b) return a == b end)
	if type(t1) ~= "table" then error("expected table as #1") end
	if type(comp) ~= "function" then error("expected function as #3") end
	if type(t2) == "table" and #t1 ~= #t2 then return false, 0 end
	for i, v in pairs(t1) do
		if type(t2) == "table" then
			if type(t1[i]) == "table" and type(t2[i]) == "table" then
				if not la.tables.match(t1[i], t2[i], comp) then return false, i end
			elseif not comp(t1[i], t2[i]) then
				return false, i
			end
		elseif type(t2) == "function" then
			if not t2(t1[i]) then
				return false, i
			end
		elseif not comp(t1[i], t2) then
			return false, i
		end
	end
	return true, nil
end

function la.table.each(t, func, iter)
	t = t or {}
	func = func or function() end
	iter = iter or pairs
	for k, v in iter(t) do
		func(k, v)
	end
end

-- ###############################################################
-- # Variables functions
-- ###############################################################

function la.variable.type(var)
	local _type = _G[cfg.replaceScope] and _G[cfg.replaceScope].type(var) or type(var)
	if(_type ~= "table" and _type ~= "userdata") then
		return _type
	end
	local _meta = getmetatable(var)
	if(_meta ~= nil and _meta.__typename ~= nil) then
		return _meta.__typename
	else
		return _type
	end
end

function la.variable.getScopes(scopePath)
	local keys = {}
	if not la.table.match({"^%.", "%.%.", "%.%[", "%][^.%[]", "%.$", "%[%]"}, scopePath, function (t, s) return not s:find(t) end) then error("scope path isn't valid") end
	local dotKeys = la.string.split(scopePath, ".")
	for i, k in ipairs(dotKeys) do
		k:gsub("([a-zA-Z0-9_]+)", function (c) table.insert(keys, c) end, 1)
		k:gsub("%[([%%#]?)([^%]]+)%]", function (i, c) table.insert(keys, i == "#" and tonumber(c) or c) end)
	end
	return keys
end

function la.variable.fromPath(scopePath, scope)
	local keys = la.variable.getScopes(scopePath)
	scope = scope or _G
	local name
	for i, v in ipairs(keys) do
		if i < #keys and type(scope) ~= "table" then error("invalid scope") end
		name = v
		if i < #keys then scope = rawget(scope, name) end
	end
	return scope, name, rawget(scope, name)
end

function la.variable.replace(name, newVar, scope)
	if type(name) ~= "string" then error("bad argument #1 to 'la.variable.replace' (string expected, got "..type(name)..")", 2) end
	scope = scope or _G
	local scope, n, v = la.variable.fromPath(name, scope)
	if cfg.strictReplace and type(v) ~= type(newVar) then error("bad argument #2 to 'la.variable.replace' ("..type(v).." expected, got "..type(newVar)..")", 2) end
	if not rawget(scope, cfg.replaceScope) then rawset(scope, cfg.replaceScope, {}) end
	local replaceScope = rawget(scope, cfg.replaceScope)
	if type(rawget(replaceScope, n)) == "nil" then
		rawset(replaceScope, n, v)
	elseif cfg.strictReplace then
		error("cannot replace an already replaced variable")
	end
	rawset(scope, n, newVar)
end

function la.variable.restore(name, scope)
	if type(name) ~= "string" then error("bad argument #1 to 'la.variable.restore' (string expected, got "..type(name)..")") end
	scope = scope or _G
	local scope, n, v = la.variable.fromPath(name, scope)
	if not rawget(scope, cfg.replaceScope) then rawset(scope, cfg.replaceScope, {}) end
	local replaceScope = rawget(scope, cfg.replaceScope)
	if type(rawget(replaceScope, n)) == "nil" then
		if cfg.strictRestore then error("cannot restore a non replaced variable") end
		return
	end
	rawset(scope, n, rawget(replaceScope, n))
	rawset(replaceScope, n, nil)
end

function la.variable.lazyType(enable)
    if (enable) then
        la.variable.replace("type", la.variable.type)
    else
        la.variable.replace("type")
    end
end

function la.variable.setType(var, typeName)
    local mt = getmetatable(var) or {}
    mt.__typename = typeName
    setmetatable(var, mt)
    return var
end

function la.variable.copyScope(scopeFrom, scopeTo, filter)

end

-- ###############################################################
-- # Function overload
-- ###############################################################

function la.newFunctionOverLoad()
	local fn = {}
	local mt = {}
	fn.functions = {}

	function mt.__index()
		error("attempt to index a function value", 2)
	end
	function mt.__newindex()
		error("attempt to index a function value", 2)
	end
	function mt.__call(self, ...)
		local arg = {...}
		for k, v in ipairs(fn.functions) do
		   local t, i = la.table.match(arg, v[1], function(a, b) return la.variable.type(a) == b end)
		   if i then print("i = "..i) end
		   if t or (i == #v[1] and v[1][#v[1]] == "...") then
		      return v[2](unpack(arg))
		   end
		end
		error("attemp to call non existent overloaded function", 2)
	end
	mt.__typename = "function"

	function fn.addFunction(params, func)
		table.insert(fn.functions, {params, func})
	end

	setmetatable(fn, mt)
	return fn
end

return la