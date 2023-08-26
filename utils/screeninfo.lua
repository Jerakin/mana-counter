-- Initiate it in your game.render_script by adding this to its init()
-- screeninfo.init(render.get_window_width(), render.get_window_height())

local M = {}

local window_width
local window_height
local project_width
local project_height
local ratio = vmath.vector3(0, 0, 0)

function M.init(initial_window_width, initial_window_height)
	window_width = initial_window_width
	window_height = initial_window_height

	project_width = sys.get_config("display.width")
	project_height = sys.get_config("display.height")
end


function M.update(width, height)
	window_width = width
	window_height = height
end


function M.get_window_width()
	return window_width
end


function M.get_window_height()
	return window_height
end


function M.get_project_width()
	return project_width
end


function M.get_project_height()
	return project_height
end


function M.get_window_ratio()
	ratio.x = window_width/project_width
	ratio.y = window_height/project_height
	return ratio
end


return M