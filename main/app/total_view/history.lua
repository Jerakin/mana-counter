local M = {}

M.history = {}
M.index = {}
function M.add(name, number)
	if number ~= 0 then
		local time = os.date("%X")
		table.insert(M.index, 1, #M.index+1)
		table.insert(M.history, 1, {time=time, name=name, number=number})
	end
end


return M