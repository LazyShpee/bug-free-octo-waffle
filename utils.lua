function int(bool) return bool and 1 or 0 end

function getIndex(scancode)
   for i, v in ipairs(const.keys) do
      if v == scancode then
	 return i
      end
   end
   return 0
end
