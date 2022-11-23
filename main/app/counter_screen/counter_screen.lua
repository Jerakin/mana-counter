local monarch = require "monarch.monarch"
local constants = require "main.app.constants"
local defsave = require("defsave.defsave")
local gesture = require "in.gesture"
local counters = require "main.app.counters"

local M = {}

M.SCENE_DATA = {}
M.SCENE_DATA.node_data = {}
M.SCENE_DATA.input_amount = 1
M.SCENE_DATA.active = {}
M.SCENE_DATA.allow_negative = false

local function create_counter(options)
	local data = {}
	local counter = gui.clone_tree(M.SCENE_DATA.template)
	local b_size = vmath.vector3(options.size.x, gui.get_height()/2, 0)
	gui.set_visible(counter["template_counter/box"], true)
	gui.set_color(counter["template_counter/box"], options.color)
	gui.set_size(counter["template_counter/box"], options.size)
	gui.set_position(counter["template_counter/box"], options.position)

	gui.set_size(counter["template_counter/add"], b_size)
	gui.set_size(counter["template_counter/remove"], b_size)
	gui.set_visible(counter["template_counter/add"], false)
	gui.set_visible(counter["template_counter/remove"], false)

	gui.play_flipbook(counter["template_counter/symbol"], options.texture)
	data.root = counter["template_counter/box"]
	data.add = counter["template_counter/add"]
	data.remove = counter["template_counter/remove"]
	data.total = counter["template_counter/text_total"]
	data.text = counter["template_counter/text"]
	return data
end

local function clear_old_nodes()
	for name in pairs(M.SCENE_DATA.node_data) do
		if M.SCENE_DATA.node_data[name].nodes ~= nil then
			for node in pairs(M.SCENE_DATA.node_data[name].nodes) do
				gui.delete_node(M.SCENE_DATA.node_data[name].nodes.root)
			end
			M.SCENE_DATA.node_data[name] = nil
		end
	end
end

local function setup()
	clear_old_nodes()
	local loaded_data = counters.loaded()
	local width = gui.get_width() / #loaded_data
	for i in pairs(loaded_data) do
		local data = loaded_data[i]
		local name = data.name
		
		if M.SCENE_DATA.node_data[name] == nil then
			M.SCENE_DATA.node_data[name] = {}
		end
		local options = {
			color=data.color, 
			texture=data.texture, 
			size = vmath.vector3(width, 640, 0),
			position = vmath.vector3((width*(i-1)+width*0.5), gui.get_height()*0.5, 0),
		}
		local counter_nodes = create_counter(options)
		M.SCENE_DATA.node_data[name].nodes = counter_nodes

		-- Set the total, keep if we already have a total
		local old_total = nil
		if M.SCENE_DATA.node_data[name].input ~= nil then
			old_total = M.SCENE_DATA.node_data[name].input.total
		end
		
		local t = old_total ~= nil and old_total or 0
		M.SCENE_DATA.node_data[name].input = {total=t}
	end
end

function M.reload()
	local settings = defsave.get("config", "settings")
	M.SCENE_DATA.allow_negative = settings.negative
	setup()
end

function M.init(self)
	msg.post(".", "acquire_input_focus")
	
	local settings = defsave.get("config", "settings")
	M.SCENE_DATA.allow_negative = settings.negative
	
	M.SCENE_DATA.template = gui.get_node("template_counter/box")
	M.SCENE_DATA.root = gui.get_node("template_counter/box")
	gui.set_visible(M.SCENE_DATA.template, false)
	
	setup()
end

local function add_operator(num)
	if num > 0 then
		return "+" .. tostring(num)
	end
	return num
end

local function increment(i)
	local n = tonumber(gui.get_text(M.SCENE_DATA.active.text))
	local add = (M.SCENE_DATA.active.mult * i)
	local capped = false
	if not M.SCENE_DATA.allow_negative then
		if n + add < 0 then
			add = -n
		end
	end
	local new_n = n + add
	M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.total = M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.total + add
	
	gui.set_text(M.SCENE_DATA.active.text, new_n)
	gui.set_text(M.SCENE_DATA.active.total, add_operator(M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.total))
	if M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.total == 0 then
		gui.set_visible(M.SCENE_DATA.active.total, false)
	else
		gui.set_visible(M.SCENE_DATA.active.total, true)
	end
	if new_n == 0 then
		gui.set_visible(M.SCENE_DATA.active.text, false)
	else
		gui.set_visible(M.SCENE_DATA.active.text, true)
	end
end

local function toggle_button(node, visible)
	gui.set_visible(node, visible)
end

function M.on_input(self, action_id, action)
	if action.pressed then
		M.SCENE_DATA.active = {}
		for name in pairs(M.SCENE_DATA.node_data) do
			local node_data = M.SCENE_DATA.node_data[name]
			if gui.pick_node(node_data.nodes.add, action.x, action.y) then
				M.SCENE_DATA.active.button = node_data.nodes.add
				M.SCENE_DATA.active.text = node_data.nodes.text
				M.SCENE_DATA.active.total = node_data.nodes.total
				M.SCENE_DATA.active.name = name
				M.SCENE_DATA.active.mult = 1
			elseif gui.pick_node(node_data.nodes.remove, action.x, action.y) then
				M.SCENE_DATA.active.button = node_data.nodes.remove
				M.SCENE_DATA.active.total = node_data.nodes.total
				M.SCENE_DATA.active.text = node_data.nodes.text
				M.SCENE_DATA.active.name = name
				M.SCENE_DATA.active.mult = -1
			end
		end
		if M.SCENE_DATA.active.button ~= nil then
			if M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.timer then
				timer.cancel(M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.timer)
			end
			gui.set_visible(M.SCENE_DATA.active.button, true)
		end
	end
	print(action.released)
	if action.released and M.SCENE_DATA.active.button then
		
		gui.set_visible(M.SCENE_DATA.active.button, false)
		local name = M.SCENE_DATA.active.name
		M.SCENE_DATA.node_data[name].input.timer = timer.delay(2, false, function() 
			gui.set_visible(M.SCENE_DATA.node_data[name].nodes.total, false)
			M.SCENE_DATA.node_data[name].input.total = 0
			M.SCENE_DATA.node_data[name].input.timer = nil
		end)
	end
	
	local g = gesture.on_input(self, action_id, action)
	if g then
		if g.tap or g.double_tap then
			increment(1)
		end

		if g.repeated then
			if action.repeated then
				increment(10)
			end
		end
	end
end

return M