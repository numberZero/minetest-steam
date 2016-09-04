-- This file is part of the steam/rotary Minetest mod

-------------------------------------------------------------------------------
-- @function gearbox_update_info
-- @param core#NodeMetaRef	meta
-- @param #number rate
-- @param #number input_speed
-- @param #number input_torque
-- @param #number output_speed
-- @param #number output_torque
local function gearbox_update_info(meta, rate, power, input_speed, input_torque, output_speed, output_torque)
	meta:set_string("formspec",
		string.format("size[4,2]"
			.."label[1.0,0.0;Gearbox]"
			.."label[0.0,0.4;Rate: %.3g]"
			.."label[0.0,0.7;Power: %s]"
			.."label[0.0,1.0;Input: %s at %s]"
			.."label[0.0,1.3;Output: %s at %s]"
			, rate
			, rotary.format_power(power)
			, rotary.format_torque(input_torque)
			, rotary.format_speed(input_speed)
			, rotary.format_torque(output_torque)
			, rotary.format_speed(output_speed)
			)
		)
	meta:set_string("infotext", string.format("Gearbox: %s -> %s, %s", rotary.format_speed(input_speed), rotary.format_speed(output_speed), rotary.format_power(power)))
end

-------------------------------------------------------------------------------
-- @function gearbox_cb
-- @param core#vector	pos
-- @param core#node	node
-- @param core#node_def	def
-- @param #number speed
-- @param core#vector dir	direction _into_ the gearbox
-- @return #number torque (consumed)
local function gearbox_cb(pos, node, def, speed, dir)
	local tripod = rotary.facedir_to_tripod_gbox(node.param2)
	if not vector.equals(dir, tripod.w) then
		return 0, 0 -- incorrect input direction
	end
	local meta = minetest.get_meta(pos)
	local rate = meta:get_float("rate") or 1
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.w)
	local output_speed = speed * rate
	local output_torque, output_inertia = 0, 0
	if cdef then
		output_torque, output_inertia = cdef.rotary.passive(cpos, cnode, cdef, output_speed, tripod.w)
	end
	local torque = output_torque * rate + 1
	local inertia = output_inertia * rate + 0.3
	gearbox_update_info(meta, rate, speed * torque, speed, torque, output_speed, output_torque)
	return torque, inertia
end

minetest.register_node("rotary:gearbox", {
	description = "Gearbox",
	tiles = {
		"rotary_dark_iron_half_block.png^rotary_output.png",
		"rotary_dark_iron_half_block.png^rotary_input.png",
		"rotary_dark_iron_half_block.png",
		"rotary_dark_iron_half_block.png",
		"rotary_dark_iron_half_block.png",
		"rotary_dark_iron_half_block.png",
	},
	groups = {
		cracky = 3,
	},
	paramtype = "light",
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			rotary.nodebox.casing_half,
			rotary.nodebox.shaft_wm,
			rotary.nodebox.shaft_wp,
		},
	},
	sunlight_propagates = true,
	on_construct = function(pos)
		rotary.init_gbox_facedir(pos)
		local meta = minetest.get_meta(pos)
		meta:set_float("rate", 2.0)
		gearbox_update_info(meta, 2.0)
	end,
--	on_receive_fields = function(pos, formname, fields, sender)
--	end,
	rotary = {
		passive = gearbox_cb,
	},
})
