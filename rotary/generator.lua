-- This file is part of the steam/rotary Minetest mod

local formspec =
		"size[8,6.5]"
		.."label[1.0,0.0;Generator]"
		.."label[1.5,0.7;Speed: %s]"
		.."label[1.5,0.4;Power: %s]"
		.."label[1.5,1.0;Torque: %s]"
		.."label[4.5,0.4;Heat power: %s]"
		.."label[4.5,0.7;Used power: %s]"
		.."label[4.5,1.0;Used torque: %s]"
		.."label[1.5,1.3;Burn time remains: %s]"
		.."label[4.5,1.3;Energy remains: %s (%s)]"
		.."list[current_name;fuel;0.5,0.5;1,1;]"
		.."list[current_player;main;0,2.25;8,1;]"
		.."list[current_player;main;0,3.5;8,3;8]"
		.."listring[current_name;dst]"
		.."listring[current_player;main]"
		.."listring[current_name;fuel]"
		.."listring[current_player;main]"

local function update_formspec(meta, inv, speed, gen_power, gen_torque, heat_power, used_power, used_torque, burn, energy, total_energy)
	meta:set_string("formspec", string.format(formspec
			, rotary.format_speed(speed)
			, rotary.format_power(gen_power)
			, rotary.format_torque(gen_torque)
			, rotary.format_power(heat_power)
			, rotary.format_power(used_power)
			, rotary.format_torque(used_torque)
			, rotary.format_time(burn)
			, rotary.format_energy(energy)
			, rotary.format_energy(total_energy)
		))
	meta:set_string("infotext", string.format("Generator: %s at %s"
			, rotary.format_power(gen_power)
			, rotary.format_speed(speed)
		))
end

local heat_power = 100e3
local eta = 0.15
local max_torque = 300
local base_inertia = 40 + 5 -- flygear of radius 0.4m and mass 500kg (apx. 13cm thick), plus internal components
local friction_torque = 10
local mode_change_speed = eta * heat_power / max_torque

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

	local tripod = rotary.facedir_to_tripod(node.param2)
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.u)
	local used_torque, added_inertia = 0, 0
	if cdef then
		used_torque, added_inertia = cdef.rotary.passive(cpos, cnode, cdef, speed, tripod.u)
	end
	local used_power = used_torque * speed
	local inertia = base_inertia + added_inertia
	local base_energy = base_inertia * speed * speed / 2
	local energy = inertia * speed * speed / 2

	update_formspec(meta, inv, speed, gen_power, gen_torque, heat_power, used_power, used_torque, burn, base_energy, energy)

	local acceleration_torque = gen_torque - used_torque - friction_torque
	local new_speed = speed + rotary.tick_length * acceleration_torque / inertia
	local stabile_speed = eta * heat_power / (used_torque + friction_torque)
	if new_speed < 0 then
		speed = 0
	elseif speed < mode_change_speed and new_speed > mode_change_speed then
		local mode1_time = (mode_change_speed - speed) * inertia / acceleration_torque
		local mode2_time = rotary.tick_length - mode1_time
		local mode2_gen_energy = mode2_time * eta * heat_power
		local mode2_consumed_energy = mode2_time * used_power -- that’s the energy we sent. a bit incorrect, but...
		local new_energy = inertia * mode_change_speed * mode_change_speed / 2 + mode2_gen_energy - mode2_consumed_energy
		speed = math.sqrt(2 * new_energy / inertia)
	else
		speed = new_speed
	end
	meta:set_float("speed", speed)

	if burn > 0 then
		burn = burn - 1
	else
		burn = 0
	end
	meta:set_int("burn", burn)
end

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
		update_formspec(meta, inv)
	end,
	rotary = {
		active = step_generator,
	},
})
