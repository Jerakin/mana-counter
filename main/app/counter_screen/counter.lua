local monarch = require "monarch.monarch"
local constants = require "main.app.constants"
local defsave = require("defsave.defsave")

local M = {}

M.SCENE_DATA = {}
M.SCENE_DATA.node_data = {}
M.SCENE_DATA.input_amount = 1
M.SCENE_DATA.active = {}

local function create_counter(options)
	local data = {}
	local counter = gui.clone_tree(M.SCENE_DATA.template)
	local b_size = vmath.vector3(options.size.x, gui.get_height()/2, 0)
	--gui.set_parent(counter["template_counter/box"], SCENE_DATA.root)
	gui.set_visible(counter["template_counter/box"], true)
	gui.set_color(counter["template_counter/box"], options.color)
	gui.set_size(counter["template_counter/box"], options.size)
	gui.set_position(counter["template_counter/box"], options.position)

	gui.set_size(counter["template_counter/add"], b_size)
	gui.set_size(counter["template_counter/remove"], b_size)
	gui.set_visible(counter["template_counter/add"], false)
	gui.set_visible(counter["template_counter/remove"], false)

	gui.play_flipbook(counter["template_counter/symbol"], options.texture)
	data.add = counter["template_counter/add"]
	data.remove = counter["template_counter/remove"]
	data.total = counter["template_counter/text_total"]
	data.text = counter["template_counter/text"]
	return data
end

local function setup(data)
	local n = 0
	for i in pairs(data) do
		if data[i].enabled then
			n = n + 1
		end
	end
	local width = gui.get_width() / n
	local index = 0
	for i in pairs(data) do
		if data[i].enabled then
			index = index + 1
			local name = data[i].name
			M.SCENE_DATA.node_data[name] = {}
			local data = constants[name]
			local options = {
				name=name,
				color=data.color, 
				texture=data.texture, 
				size = vmath.vector3(width, 640, 0),
				position = vmath.vector3((width*(index-1)+width*0.5), gui.get_height()*0.5, 0),
			}
			local counter = create_counter(options)
			M.SCENE_DATA.node_data[name].nodes = counter
			M.SCENE_DATA.node_data[name].input = {total=0}
		end
	end
end

function M.init(self)
	local counter = defsave.get("config", "counter")
	msg.post(".", "acquire_input_focus")
	M.SCENE_DATA.template = gui.get_node("template_counter/box")
	M.SCENE_DATA.root = gui.get_node("template_counter/box")
	setup(counter)
	gui.set_visible(M.SCENE_DATA.template, false)
end

local function add_operator(num)
	if num > 0 then
		return "+" .. tostring(num)
	end
	return num
end

local function increment(i)
	local n = gui.get_text(M.SCENE_DATA.active.text)
	local add = (M.SCENE_DATA.active.mult * i)
	local new_n = tonumber(n) + add
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
	if action_id == hash("touch") then
		if action.pressed then
			M.SCENE_DATA.repeated = false
			M.SCENE_DATA.active = {}
		end

		for name in pairs(M.SCENE_DATA.node_data) do
			local node_data = M.SCENE_DATA.node_data[name]
			if action.pressed then
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
				if M.SCENE_DATA.active.button then
					if M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.timer then
						timer.cancel(M.SCENE_DATA.node_data[M.SCENE_DATA.active.name].input.timer)
					end
					gui.set_visible(M.SCENE_DATA.active.button, true)
				end
			end
		end
		if not action.pressed and action.repeated then
			M.SCENE_DATA.repeated = true
			increment(10)
		elseif action.released and M.SCENE_DATA.active.button then
			if not M.SCENE_DATA.repeated then
				increment(1)
			end
			gui.set_visible(M.SCENE_DATA.active.button, false)
			local name = M.SCENE_DATA.active.name
			M.SCENE_DATA.node_data[name].input.timer = timer.delay(2, false, function() 
				gui.set_visible(M.SCENE_DATA.node_data[name].nodes.total, false)
				M.SCENE_DATA.node_data[name].input.total = 0
				M.SCENE_DATA.node_data[name].input.timer = nil
			end)
		end
	end
end

return M