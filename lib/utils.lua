function int(bool) return bool and 1 or 0 end
function bool(int) return int ~= 0 end
function tuple(...) return la.variable.setType({ ... }, "tuple") end

function getIndex(scancode)
   for i, v in pairs(const.keys) do
      if v == scancode then
	 return i
      end
   end
   return 0
end

function deepcopy(orig)
   if not orig then
      return
   end
   local copy = {}

   if type(orig) == 'table' then
      for k, v in pairs(orig) do
	 copy[deepcopy(k)] = deepcopy(v)
      end
      setmetatable(copy, getmetatable(orig))
   else
      copy = orig
   end
   return copy
end

function merge(dest, src)
   for k, v in pairs(src) do
      dest[k] = v
   end
end

function npairs(t, ...)
  local i, a, k, v = 1, {...}
  return
    function()
      repeat
        k, v = next(t, k)
        if k == nil then
          i, t = i + 1, a[i]
        end
      until k ~= nil or not t
      return k, v
    end
end
