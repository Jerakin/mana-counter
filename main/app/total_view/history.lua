local constants = require "main.app.constants"
local defsave = require("defsave.defsave")

local M = {}

M.history = {}
M.index = {}
function M.add(name, number)
	if number ~= 0 then
		local time = os.date("%X")
		table.insert(M.index, 1, #M.index+1)
		table.insert(M.history, 1, {time=time, name=name, number=number})
		M.save()
	end
end

function M.clear()
	M.history = {}
	M.index = {}
end

function M.save()
	defsave.set(constants.SAVE_CONFIG, "history", {history=M.history, index=M.index})
end

function M.load()
	local data = defsave.get(constants.SAVE_CONFIG, "history")
	if data then
		M.history = data.history
		M.index = data.index
	end
end

return M