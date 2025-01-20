local monarch = require "monarch.monarch"
local constants = require "main.app.constants"
local defsave = require("defsave.defsave")
local gesture = require "in.gesture"
local counters = require "main.app.counters"
local url = require "utils.url"
local history = require "main.app.total_view.history"

local M = {}

M.SCENE_DATA = {}
M.SCENE_DATA.node_data = {}
M.SCENE_DATA.counters = {}
M.SCENE_DATA.input_amount = 1
M.SCENE_DATA.active = {}
M.SCENE_DATA.allow_negative = false

local SECONDS_FOR_HINT = 3

local function create_counter(options)
	local data = {}
	local counter = gui.clone_tree(M.SCENE_DATA.template)
	local b_size = vmath.vector3(options.size.x, gui.get_height()/2, 0)

	data.root = counter["template_counter/box"]
	data.add = counter["template_counter/add"]
	data.remove = counter["template_counter/remove"]
	data.total_p = counter["template_counter/text_total_positive"]
	data.total_n = counter["template_counter/text_total_negative"]
	data.text = counter["template_counter/text"]
	data.symbol = counter["template_counter/symbol"]
	
	gui.set_visible(data.root, true)
	gui.set_color(data.root, options.color)
	gui.set_size(data.root, options.size)
	gui.set_position(data.root, options.position)

	gui.set_size(data.add, b_size)
	gui.set_size(data.remove, b_size)
	gui.set_visible(data.add, false)
	gui.set_visible(data.remove, false)
	gui.play_flipbook(data.symbol, options.texture)
	
	if M.SCENE_DATA.counters[options.name] ~= nil then
		if M.SCENE_DATA.counters[options.name] ~= 0 then
			gui.set_visible(data.text, true)
		end
		gui.set_text(data.text, M.SCENE_DATA.counters[options.name])
	end
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

function M.get_counter_sum()
	local total = 0

	for name in pairs(M.SCENE_DATA.counters) do
		local is_mana = counters.get(name)
		if is_mana ~= nil and is_mana.is_default and (is_mana.enabled == nil or is_mana.enabled) then
			total = total + M.SCENE_DATA.counters[name]
		end
	end
	return total
end

local function setup()
	clear_old_nodes()
	local loaded_data = counters.loaded()
	local width = gui.get_width() / #loaded_data
	for i in pairs(loaded_data) do
		local data = loaded_data[i]
		local name = data.name
		if M.SCENE_DATA.counters[name] == nil then
			M.SCENE_DATA.counters[name] = 0
		end
		if M.SCENE_DATA.node_data[name] == nil then
			M.SCENE_DATA.node_data[name] = {}
		end

		local options = {
			name=name,
			color=data.color, 
			texture=data.texture, 
			size = vmath.vector3(width, 640, 0),
			position = vmath.vector3((width*(i-1)+width*0.5), gui.get_height()*0.5, 0),
		}
		local counter_nodes = create_counter(options)
		M.SCENE_DATA.node_data[name].nodes = counter_nodes

		-- Set the total, keep if we already have a total
		local t = 0
		if M.SCENE_DATA.node_data[name].input ~= nil then
			t = M.SCENE_DATA.node_data[name].input.total
		end
		
		M.SCENE_DATA.node_data[name].input = {total=t}
	end
end

local function add_operator(num)
	if num > 0 then
		return "+" .. tostring(num)
	end
	return num
end

local function save_data()
	defsave.set(constants.SAVE_DATA, 'counters', M.SCENE_DATA.counters)
	defsave.save(constants.SAVE_DATA)
end


local function increment(i)
	local n = tonumber(gui.get_text(M.SCENE_DATA.active.text))
	local add = (M.SCENE_DATA.active.mult * i)
	local name = M.SCENE_DATA.active.name
	if not M.SCENE_DATA.allow_negative then
		if n + add < 0 then
			add = -n
		end
	end

	M.SCENE_DATA.node_data[name].input.total = M.SCENE_DATA.node_data[name].input.total + add
	M.SCENE_DATA.counters[name] = M.SCENE_DATA.counters[name] + add
	
	gui.set_text(M.SCENE_DATA.active.text, M.SCENE_DATA.counters[name])
	gui.set_text(M.SCENE_DATA.active.total_p, add_operator(M.SCENE_DATA.node_data[name].input.total))
	gui.set_text(M.SCENE_DATA.active.total_n, add_operator(M.SCENE_DATA.node_data[name].input.total))
	if M.SCENE_DATA.node_data[name].input.total == 0 then
		gui.set_visible(M.SCENE_DATA.active.total_n, false)
		gui.set_visible(M.SCENE_DATA.active.total_p, false)
	else
		if M.SCENE_DATA.node_data[name].input.total > 0 then
			gui.set_visible(M.SCENE_DATA.active.total_p, true)
			gui.set_visible(M.SCENE_DATA.active.total_n, false)
		else
			gui.set_visible(M.SCENE_DATA.active.total_n, true)
			gui.set_visible(M.SCENE_DATA.active.total_p, false)
		end
	end
	if M.SCENE_DATA.counters[name] == 0 then
		gui.set_visible(M.SCENE_DATA.active.text, false)
	else
		gui.set_visible(M.SCENE_DATA.active.text, true)
	end

	save_data()
	msg.post(url.total_view, "update_total", {text=M.get_counter_sum()})
end

local function toggle_button(node, visible)
	gui.set_visible(node, visible)
end

function M.delete(name)
	M.SCENE_DATA.counters[name] = nil
	if M.SCENE_DATA.active.name == name then
		M.SCENE_DATA.active = {}
	end
end

function M.reset()
	local settings = defsave.get(constants.SAVE_CONFIG, "settings")
	for name, data in pairs(M.SCENE_DATA.counters) do
		if not counters.data[name].is_default and settings.reset_custom then
			M.SCENE_DATA.counters[name] = 0
		elseif counters.data[name].is_default then
			M.SCENE_DATA.counters[name] = 0
		end
	end
end

function M.reload()
	local settings = defsave.get(constants.SAVE_CONFIG, "settings")
	M.SCENE_DATA.allow_negative = settings.negative
	setup()
	msg.post(url.total_view, "update_total", {text=M.get_counter_sum()})
end

local function fix_1_1_5(counter_data)
	for name, d in pairs(M.SCENE_DATA.counters) do
		if counters.data[name] == nil then
			M.SCENE_DATA.counters[name] = nil
		end
	end
end

function M.init(self)
	local settings = defsave.get(constants.SAVE_CONFIG, "settings")
	local counters = defsave.get(constants.SAVE_DATA, 'counters')
	M.SCENE_DATA.counters = counters or {}
	M.SCENE_DATA.allow_negative = settings.negative

	M.SCENE_DATA.template = gui.get_node("template_counter/box")
	M.SCENE_DATA.root = gui.get_node("template_counter/box")
	gui.set_visible(M.SCENE_DATA.template, false)

	fix_1_1_5()

	setup()
end

function M.on_input(self, action_id, action)
	if action_id ~= hash("touch") then
		return 
	end
	local valid = false
	if action.pressed then
		M.SCENE_DATA.active = {}
		for name in pairs(M.SCENE_DATA.node_data) do
			local node_data = M.SCENE_DATA.node_data[name]
			if gui.pick_node(node_data.nodes.add, action.x, action.y) then
				M.SCENE_DATA.active.button = node_data.nodes.add
				M.SCENE_DATA.active.text = node_data.nodes.text
				M.SCENE_DATA.active.total_n = node_data.nodes.total_n
				M.SCENE_DATA.active.total_p = node_data.nodes.total_p
				M.SCENE_DATA.active.name = name
				M.SCENE_DATA.active.mult = 1
			elseif gui.pick_node(node_data.nodes.remove, action.x, action.y) then
				M.SCENE_DATA.active.button = node_data.nodes.remove
				M.SCENE_DATA.active.total_n = node_data.nodes.total_n
				M.SCENE_DATA.active.total_p = node_data.nodes.total_p
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

	if action.released and M.SCENE_DATA.active.button then
		valid = true
		gui.set_visible(M.SCENE_DATA.active.button, false)
		local name = M.SCENE_DATA.active.name
		M.SCENE_DATA.node_data[name].input.timer = timer.delay(SECONDS_FOR_HINT, false, function()
			if M.SCENE_DATA.node_data[name] ~= nil then
				history.add(name, M.SCENE_DATA.node_data[name].input.total)
				gui.set_visible(M.SCENE_DATA.node_data[name].nodes.total_p, false)
				gui.set_visible(M.SCENE_DATA.node_data[name].nodes.total_n, false)
				M.SCENE_DATA.node_data[name].input.total = 0
				M.SCENE_DATA.node_data[name].input.timer = nil
			end
		end)
	end
	
	local g = gesture.on_input(self, action_id, action)
	if g then
		if valid and g.tap or g.double_tap then
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