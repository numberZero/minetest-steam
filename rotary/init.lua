-- This file is part of the steam/rotary Minetest mod

rotary = {}

rotary.nodebox = {
	casing_full	= {-0.500, -0.500, -0.500, 0.500, 0.500, 0.500},
	casing_half	= {-0.250, -0.250, -0.250, 0.250, 0.250, 0.250},
	shaft_x	= {-0.500, -0.125, -0.125, 0.500, 0.125, 0.125},
	shaft_y	= {-0.125, -0.500, -0.125, 0.125, 0.500, 0.125},
	shaft_z	= {-0.125, -0.125, -0.500, 0.125, 0.125, 0.500},
	shaft_xm	= {-0.500, -0.125, -0.125, -0.250, 0.125, 0.125},
	shaft_xp	= {0.250, -0.125, -0.125, 0.500, 0.125, 0.125},
	shaft_ym	= {-0.125, -0.500, -0.125, 0.125, -0.250, 0.125},
	shaft_yp	= {-0.125, 0.250, -0.125, 0.125, 0.500, 0.125},
	shaft_zm	= {-0.125, -0.125, -0.500, 0.125, 0.125, -0.250},
	shaft_zp	= {-0.125, -0.125, 0.250, 0.125, 0.125, 0.500},
	input_ym	= {-0.0625, -0.5625, -0.0625, 0.0625, 0.5000, 0.0625},
}

rotary.nodebox.shaft_u = rotary.nodebox.shaft_z
rotary.nodebox.shaft_v = rotary.nodebox.shaft_x
rotary.nodebox.shaft_w = rotary.nodebox.shaft_y
rotary.nodebox.shaft_um = rotary.nodebox.shaft_zm
rotary.nodebox.shaft_vm = rotary.nodebox.shaft_xm
rotary.nodebox.shaft_wm = rotary.nodebox.shaft_ym
rotary.nodebox.shaft_up = rotary.nodebox.shaft_zp
rotary.nodebox.shaft_vp = rotary.nodebox.shaft_xp
rotary.nodebox.shaft_wp = rotary.nodebox.shaft_yp
rotary.nodebox.input_wm = rotary.nodebox.input_ym

rotary.time_speed = tonumber(minetest.setting_get("time_speed"))
rotary.tick_length = rotary.time_speed

local path = minetest.get_modpath("rotary")
dofile(path.."/util.lua")
dofile(path.."/craftitems.lua")
dofile(path.."/shaft.lua")
dofile(path.."/gearbox.lua")
dofile(path.."/splitter.lua")
dofile(path.."/generator.lua")

function rotary.get_consumer(pos, dir)
	local npos = vector.add(pos, dir)
	local node = minetest.get_node(npos)
	local def = minetest.registered_nodes[node.name]
	if def.rotary and def.rotary.passive then
		return npos, node, def
	end
	return nil
end

local initial_gearbox_facedir = { [0] = 14, 11, 16, 5 }

function rotary.init_gbox_facedir(pos)
	local node = minetest.get_node(pos)
	if node.param2 >= 4 then return end
	node.param2 = initial_gearbox_facedir[node.param2]
	minetest.swap_node(pos, node)
end

-------------------------------------------------------------------------------
-- @function consume_1
-- @param core#vector	pos
-- @param core#node	node
-- @param core#node_def	def
-- @param #number speed
-- @param core#vector dir	direction _into_ the consumer
-- @return #number torque (consumed)
-- @return #number inertia (added)
local function consume_1(pos, node, def, speed, dir)
	local tripod = rotary.facedir_to_tripod(node.param2)
	if not vector.equals(dir, tripod.u) then
		return 0, 0 -- incorrect input direction
	end
	local meta = minetest.get_meta(pos)
	meta:set_float("input_speed", speed) 
	meta:set_string("formspec", 
		"size[4,2]"
		.."label[0.5,0.5;Speed: "..speed.."]"
		)
	return 100, 160
end

-------------------------------------------------------------------------------
-- @function step_generator_1
-- @param core#vector	pos	is the position of the node
-- @param core#node	node	is the node
-- @param core#node_def	def
local function step_generator_1(pos, node, def)
	local meta = minetest.get_meta(pos)
	local tripod = rotary.facedir_to_tripod(node.param2)
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.u)
	local speed = 20.0
	local torque = cdef and cdef.rotary.passive(cpos, cnode, cdef, speed, tripod.u) or 0
	local power = torque * speed
	meta:set_float("speed", speed);
	meta:set_string("formspec", 
		"size[3,1.3]"
		.."label[0.5,0.0;Admin Generator]"
		.."label[0,0.4;Speed: "..speed.." rad/s]"
		.."label[0,0.7;Power: "..power.." W]"
		.."label[0,1.0;Torque: "..torque.." N•m]"
		)
end

-------------------------------------------------------------------------------
-- @function step_node
-- @param core#vector	pos	is the position of the node
-- @param core#node	node	is the node
local function step_node(pos, node)
	local def = minetest.registered_nodes[node.name]
	if def.rotary and def.rotary.active then
		return def.rotary.active(pos, node, def)
	end
	minetest.log("error", "rotary:step_node called for non-rotary-compatible node "..node.name.." at "..minetest.pos_to_string(pos))
end

minetest.register_node("rotary:consumer", {
	description = "Rotation consumer",
	tiles = {
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png^rotary_input.png",
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png",
	},
	groups = {
		cracky = 3,
	},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[4,2]label[1.0,0.0;Consumer]")
	end,
	rotary = {
		passive = consume_1,
	},
})

minetest.register_node("rotary:engine_admin", {
	description = "Admin Engine",
	tiles = {
		"default_diamond_block.png",
		"default_diamond_block.png",
		"default_diamond_block.png^rotary_output.png",
		"default_diamond_block.png",
		"default_diamond_block.png",
		"default_diamond_block.png"
	},
	groups = {
		cracky = 3,
		rotary_active = 1
	},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "size[4,2.2]label[1,0.0;Admin Generator]")
	end,
	rotary = {
		active = step_generator_1,
	},
})

minetest.register_abm({
	nodenames = {
		"group:rotary_active",
	},
	interval = 1,
	chance = 1,
	action = step_node,
})

return rotary
