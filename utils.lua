function int(bool) return bool and 1 or 0 end
function bool(int) return int ~= 0 end

function getIndex(scancode)
   for i, v in pairs(const.keys) do
      if v == scancode then
	 return i
      end
   end
   return 0
end

function tuple(...) return la.variable.setType({ ... }, "tuple") end
