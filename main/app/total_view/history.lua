M = {}

M.history = {}

function M.add(name, number)
	if number ~= 0 then
		local time = os.date("%X")
		
		local string = string.format("%-18s %s", time .. " " .. name, number)
		table.insert(M.history, 1, string)
	end
end


return M