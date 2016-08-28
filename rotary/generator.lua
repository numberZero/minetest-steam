-- This file is part of the steam/rotary Minetest mod

local formspec =
		"size[8,6.5]"
		.."label[1.0,0.0;Generator]"
		.."label[1.5,0.7;Speed: %.2f s⁻¹]"
		.."label[1.5,0.4;Power: %.1f W]"
		.."label[1.5,1.0;Torque: %.2f N•m]"
		.."label[4.5,0.4;Heat power: %.1f W]"
		.."label[4.5,0.7;Used power: %.1f W]"
		.."label[4.5,1.0;Used torque: %.2f N•m]"
		.."label[1.5,1.3;Burn time remains: %d s]"
		.."label[4.5,1.3;Energy remains: %.1f J]"
		.."list[current_name;fuel;0.5,0.5;1,1;]"
		.."list[current_player;main;0,2.25;8,1;]"
		.."list[current_player;main;0,3.5;8,3;8]"
		.."listring[current_name;dst]"
		.."listring[current_player;main]"
		.."listring[current_name;fuel]"
		.."listring[current_player;main]"

local function update_formspec(meta, inv, ...)
	meta:set_string("formspec", string.format(formspec, ...))
	meta:set_string("infotext", string.format("Generator at %.1f rps, %.0f W", ...))
end

local heat_power = 10000
local eta = 0.45
local max_torque = 10000
local inertia = 50000

local function step_generator(pos, node, def)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local burn = meta:get_int("burn")
	local speed = meta:get_float("speed")
	local gen_power = 0
	local gen_torque = 0
	if burn <= 0 then
		local fuel = inv:get_list("fuel")
		local new_burn, rem_fuel = minetest.get_craft_result({ method = "fuel", width = 1, items = fuel})
		if new_burn and new_burn.time > 0 then
			burn = new_burn.time
			inv:set_list("fuel", rem_fuel.items)
		end
	end
	if burn > 0 then -- if active
		gen_power = eta * heat_power
		gen_torque = gen_power / speed
		if gen_torque > max_torque then
			gen_torque = max_torque
			gen_power = gen_torque * speed
		end
	end

	local energy = inertia * speed * speed / 2

	local tripod = rotary.facedir_to_tripod(node.param2)
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.u)
	local used_torque = cdef and cdef.rotary.passive(cpos, cnode, cdef, speed, tripod.u) or 0
	local used_power = used_torque * speed

	update_formspec(meta, inv, speed, gen_power, gen_torque, heat_power, used_power, used_torque, burn, energy)

	local acceleration_torque = gen_torque - used_torque
	local acceleration = acceleration_torque / inertia
	speed = speed + acceleration_torque / inertia
	if speed < 0 then
		speed = 0
	end
	meta:set_float("speed", speed)

	if burn > 0 then
		burn = burn - 1
	else
		burn = 0
	end
	meta:set_int("burn", burn)
end

-- 	local generated_torque = 100;
-- 	local used_torque = cdef and cdef.rotary.passive(cpos, cnode, cdef, speed, tripod.u) or 0
-- 	local acceleration_torque = generated_torque - used_torque
-- 	local acceleration = acceleration_torque / 10.0
-- 	local friction = 0.05
-- 	speed = speed + acceleration
-- 	speed = (1 - friction) * speed
-- 	if speed < 0 then
-- 		speed = 0
-- 	end
-- 	local stable = acceleration * (1 - friction) / friction
-- 	meta:set_float("speed", speed);
-- 	meta:set_string("formspec", 
-- 		"size[4,2.2]"
-- 		.."label[1,0.0;Admin Generator]"
-- 		.."label[0,0.4;Speed: "..speed.."]"
-- 		.."label[0,0.7;Generation: "..generated_torque.."]"
-- 		.."label[0,1.0;Usage: "..used_torque.."]"
-- 		.."label[0,1.3;Acceleration: "..acceleration.."]"
-- 		.."label[0,1.6;Friction: "..friction.."]"
-- 		.."label[0,1.9;Stable speed: "..stable.."]"
-- 		)

minetest.register_node("rotary:engine_fuel", {
	description = "Self-contained rotary engine (fuel-fired)",
	tiles = {
		"default_furnace_top.png",
		"default_furnace_bottom.png",
		"default_furnace_side.png^rotary_output.png",
		"default_furnace_side.png",
		"default_furnace_side.png",
		"default_furnace_front.png",
	},
	groups = {
		cracky = 3,
		rotary_active = 1
	},
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('fuel', 1)
		update_formspec(meta, inv, 0, 0, 0, 0, 0, 0, 0, 0)
	end,
	rotary = {
		active = step_generator,
	},
})
