-- This file is part of the steam/rotary Minetest mod

local function splitter_update_info(meta, speed, input_torque, oforward_torque, oright_torque, oleft_torque, oup_torque, odown_torque)
	local power = speed * input_torque
	meta:set_string("formspec",
		string.format("size[4,3.1]"
			.."label[1.0,0.0;Splitter]"
			.."label[0.0,0.4;Power: %s]"
			.."label[0.0,0.7;Speed: %s]"
			.."label[0.0,1.0;Input: %s]"
			.."label[0.0,1.3;Outputs:]"
			.."label[0.5,1.6;%s forward]"
			.."label[0.5,2.2;%s right]"
			.."label[0.5,1.9;%s left]"
			.."label[0.5,2.5;%s up]"
			.."label[0.5,2.8;%s down]"
			, rotary.format_power(power)
			, rotary.format_speed(speed)
			, rotary.format_torque(input_torque)
			, rotary.format_torque(oforward_torque)
			, rotary.format_torque(oright_torque)
			, rotary.format_torque(oleft_torque)
			, rotary.format_torque(oup_torque)
			, rotary.format_torque(odown_torque)
			)
		)
	meta:set_string("infotext", string.format("Splitter %s, %s", rotary.format_speed(speed), rotary.format_power(power)))
end

local function splitter_cb(pos, node, def, speed, dir)
	local tripod = rotary.facedir_to_tripod_gbox(node.param2)
	if not vector.equals(dir, tripod.w) then
		return 0, 0 -- incorrect input direction
	end
	local meta = minetest.get_meta(pos)
	local output_dir = { tripod.w, tripod.u, tripod.u.n, tripod.v, tripod.v.n }
	local output_torque = {}
	local torque = 3
	local inertia = 1
	for i, dir in ipairs(output_dir) do
		local cpos, cnode, cdef = rotary.get_consumer(pos, dir)
		local torque1, inertia1 = 0, 0
		if cdef then
			torque1, inertia1 = cdef.rotary.passive(cpos, cnode, cdef, speed, dir)
		end
		output_torque[i] = torque1
		torque = torque + torque1
		inertia = inertia + inertia1
	end
	splitter_update_info(meta, speed, torque, unpack(output_torque))
	return torque, inertia
end

minetest.register_node("rotary:splitter", {
	description = "Frictionless Splitter",
	tiles = {
		"rotary_dark_iron_half_block.png^rotary_output.png",
		"rotary_dark_iron_half_block.png^rotary_input.png",
		"rotary_dark_iron_half_block.png^rotary_output.png",
		"rotary_dark_iron_half_block.png^rotary_output.png",
		"rotary_dark_iron_half_block.png^rotary_output.png",
		"rotary_dark_iron_half_block.png^rotary_output.png",
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
			rotary.nodebox.shaft_u,
			rotary.nodebox.shaft_v,
			rotary.nodebox.shaft_w,
			rotary.nodebox.input_wm,
		},
	},
	sunlight_propagates = true,
	on_construct = function(pos)
		rotary.init_gbox_facedir(pos)
		local meta = minetest.get_meta(pos)
		splitter_update_info(meta, 0, 0, 0, 0, 0, 0, 0)
	end,
	rotary = {
		passive = splitter_cb,
	},
})
