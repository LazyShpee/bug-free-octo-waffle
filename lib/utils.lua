function int(bool) return bool and 1 or 0 end
function bool(int) return int ~= 0 end
function tuple(...) return la.variable.setType({ ... }, "tuple") end
function ghost() end

function getIndex(t, item)
   for i, v in pairs(t) do
      if v == item then
	 return i
      end
   end
   return 0
end

function deepcopy(orig, nometa)
   if not orig then
      return
   end
   local copy, omt, cmt = {}

   if type(orig) == 'table' then
      for k, v in pairs(orig) do
	 copy[k] = deepcopy(v)
      end
      if not nometa then
	 mt = getmetatable(orig)
	 for k, v in pairs(mt) do
	    cmt[k] = deepcopy(v)
	 end
	 setmetatable(copy, cmt)
      end
   else
      copy = orig
   end
   return copy
end

function merge(dest, src)
   for k, v in pairs(src) do
      dest[k] = v
   end
   local dmt = getmetatable(dest) or {}
   local smt = getmetatable(src) or {}
   for k, v in pairs(smt) do
      dmt[k] = v
   end
   return setmetatable(dest, dmt)
end

function npairs(t, ...)
   --
   -- Usage:
   --  for k, v in npairs({ 42, 69 }, { 360, 420 }) do print(k, v) end
   --
   local args = { t, ... }
   local i = 1
   local k, v
   return function()
      k, v = next(t, k)
      if not k then
	 i, t = next(args, i)
	 if i then
	    k, v = next(t, k)
	 end
      end
      return k, v
   end
end

function rconcat(dest, src) -- concat and copy contant to src
   local tmp = deepcopy(src)
   local ct = 1
   for k, v in npairs(dest, tmp) do
      if type(k) ~= "number" then
	 src[k] = v
      else
	 src[ct] = v
	 ct = ct + 1
      end
   end
   return src
end

function concat(dest, src) -- concat and copy contant to dest
   local tmp = deepcopy(dest)
   local ct = 1
   for _, v in npairs(tmp, src) do
      if type(k) ~= "number" then
	 src[k] = v
      else
	 dest[ct] = v
	 ct = ct + 1
      end
   end
   return dest
end

function addToMetatable(t, k, v)
   local mt = getmetatable(t)
   if not mt then
      mt = {}
      setmetatable(t, mt)
   end
   mt[k] = v
end
