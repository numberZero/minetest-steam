-------------------------------------------------------------------------------
-- @module rotary
rotary = {}

local path = minetest.get_modpath("rotary")
dofile(path.."/util.lua")
dofile(path.."/gearbox.lua")

function rotary.get_consumer(pos, dir)
	local npos = vector.add(pos, dir)
	local node = minetest.get_node(npos)
	local def = minetest.registered_nodes[node.name]
	if def.rotary and def.rotary.passive then
		return npos, node, def
	end
	return nil
end

-------------------------------------------------------------------------------
-- @function consume_1
-- @param core#vector	pos
-- @param core#node	node
-- @param core#node_def	def
-- @param #number speed
-- @param core#vector dir	direction _into_ the consumer
-- @return #number torque (consumed)
local function consume_1(pos, node, def, speed, dir)
	local meta = minetest.get_meta(pos)
	meta:set_float("input_speed", speed) 
	meta:set_string("formspec", 
		"size[4,2]"
		.."label[0.5,0.5;Speed: "..speed.."]"
		)
	return 30
end

-------------------------------------------------------------------------------
-- @function step_generator_1
-- @param core#vector	pos	is the position of the node
-- @param core#node	node	is the node
-- @param core#node_def	def
local function step_generator_1(pos, node, def)
	local meta = minetest.get_meta(pos)
	local speed = meta:get_float("speed");
	local tripod = rotary.facedir_to_tripod(node.param2)
--	print("Direction: " .. dump(tripod.u))
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.u)
	local generated_torque = 100;
	local used_torque = cdef and cdef.rotary.passive(cpos, cnode, cdef, speed, tripod.u) or 0
	local acceleration_torque = generated_torque - used_torque
	local acceleration = acceleration_torque / 10.0
	local friction = 0.05
	speed = speed + acceleration
	speed = (1 - friction) * speed
	if speed < 0 then
		speed = 0
	end
	local stable = acceleration * (1 - friction) / friction
	meta:set_float("speed", speed);
	meta:set_string("formspec", 
		"size[4,2.2]"
		.."label[1,0.0;Admin Generator]"
		.."label[0,0.4;Speed: "..speed.."]"
		.."label[0,0.7;Generation: "..generated_torque.."]"
		.."label[0,1.0;Usage: "..used_torque.."]"
		.."label[0,1.3;Acceleration: "..acceleration.."]"
		.."label[0,1.6;Friction: "..friction.."]"
		.."label[0,1.9;Stable speed: "..stable.."]"
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

local formspec =
	"size[8,8.5]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[current_name;fuel;2.75,2.5;1,1;]"..
	"list[current_player;main;0,4.25;8,1;]"..
	"list[current_player;main;0,5.5;8,3;8]"..
	"listring[current_name;dst]"..
	"listring[current_player;main]"..
	"listring[current_name;fuel]"..
	"listring[current_player;main]"..
	default.get_hotbar_bg(0, 4.25)

minetest.register_node("rotary:consumer", {
	description = "Rotation consumer",
	tiles = {
		"default_steel_block.png",
		"default_steel_block.png",
		"default_steel_block.png",
		"default_copper_block.png",
		"default_steel_block.png",
		"default_steel_block.png"
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
--		run = step_consumer_1,
		passive = consume_1,
	},
})

minetest.register_node("rotary:engine_fuel", {
	description = "Self-contained rotary engine (fuel-fired)",
	tiles = {
		"default_furnace_top.png",
		"default_furnace_bottom.png",
		"default_bronze_block.png",
		"default_furnace_side.png",
		"default_furnace_side.png",
		"default_furnace_front.png"
	},
	groups = {
		cracky = 3,
		rotary_active = 1
	},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formspec)
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
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
