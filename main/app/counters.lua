local constants = require "main.app.constants"
local defsave = require("defsave.defsave")

local M = {}
M.data = {}
M.counter = nil


--[[

defsave.default_data.config = {
	counter={
		{name="White", enabled=true}, 
		{name="Blue", enabled=true}, 
		{name="Black", enabled=true}, 
		{name="Red", enabled=true}, 
		{name="Green", enabled=true},
		{name="Colorless", enabled=false}
	},

--]]

-- Default
M.data.White = {}
M.data.White.color = vmath.vector3(252/255, 253/255, 180/255)
M.data.White.texture = "w"
M.data.White.is_default = true

M.data.Blue = {}
M.data.Blue.color =      vmath.vector3(87/255, 179/255, 242/255)
M.data.Blue.texture = "u"
M.data.Blue.is_default = true

M.data.Black = {}
M.data.Black.color =     vmath.vector3(113/255, 113/255, 113/255)
M.data.Black.texture = "b"
M.data.Black.is_default = true

M.data.Red = {}
M.data.Red.color =       vmath.vector3(243/255, 60/255, 67/255)
M.data.Red.texture = "r"
M.data.Red.is_default = true

M.data.Green = {}
M.data.Green.color =     vmath.vector3(37/255, 170/255, 86/255)
M.data.Green.texture = "g"
M.data.Green.is_default = true

M.data.Colorless = {}
M.data.Colorless.color = vmath.vector3(227/255, 227/255, 227/255)
M.data.Colorless.texture = "c"
M.data.Colorless.is_default = true

function M.loaded()
	local t = {}
	for i in pairs(M.counter) do
		local data = M.counter[i]
		if data.enabled then
			local c = M.data[data.name]
			c.name = data.name
			table.insert(t, c)
		end
	end
	return t
end


function M.all()
	local t = {}
	for i in pairs(M.counter) do
		local data = M.counter[i]
		local c = M.data[data.name]
		c.name = data.name
		c.enabled = data.enabled

		table.insert(t, c)
	end
	return t
end

function M.get(name)
	local c = M.data[name]
	if M.counter[name] then
		c.enabled = M.counter[name].enabled
	end
	return c
end

function M.add(name, data)
	if M.data[name] == nil then 
		M.data[name] = {color = data.color, texture=data.texture}
		table.insert(M.counter, {name=name, enabled=true})
		return true
	end
	return false
end


function M.delete(name)
	M.data[name] = nil
	for i in pairs(M.counter) do
		local data = M.counter[i]
		if data.name == name then
			table.remove(M.counter, i)
			return true
		end
	end
end

function M.number_of_custom()
	local n = 0
	for name in pairs(M.data) do
		if M.data[name].is_default == nil then
			n = n + 1
		end
	end
	return n
end

function M.load()
	M.counter = defsave.get(constants.SAVE_CONFIG, "counter")
	local extra = defsave.get(constants.SAVE_CONFIG, "extra")
	if extra ~=nil then
		for i in pairs(extra) do
			local data = extra[i]
			M.data[data.name] = {color = data.color, texture=data.texture}
		end
	end
end

function M.set_visible(name, visible)
	for i in pairs(M.counter) do
		local data = M.counter[i]
		if data.name == name then
			data.enabled = visible
		end
	end
	
end

function M.save()
	local extra = {}
	local all_data = M.all()
	for i in pairs(all_data) do
		local data = all_data[i]
		if data.is_default == nil then
			table.insert(extra, {color=data.color, texture=data.texture, name=data.name})
		end
	end
	defsave.set(constants.SAVE_CONFIG, "extra", extra)
	defsave.set(constants.SAVE_CONFIG, "counter", M.counter)
	defsave.save(constants.SAVE_DATA)
	defsave.save(constants.SAVE_CONFIG)
end

return M