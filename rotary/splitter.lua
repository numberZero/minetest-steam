-- This file is part of the steam/rotary Minetest mod

local function splitter_update_info(meta, speed, input_torque, oforward_torque, oright_torque, oleft_torque, oup_torque, odown_torque)
	local power = speed * input_torque
	meta:set_string("formspec",
		string.format("size[4,3.1]"
			.."label[1.0,0.0;Splitter]"
			.."label[0.0,0.4;Power: %.1f Wt]"
			.."label[0.0,0.7;Speed: %.2f s⁻¹]"
			.."label[0.0,1.0;Input: %.2f N•m]"
			.."label[0.0,1.3;Outputs:]"
			.."label[0.5,1.6;%.2f N•m forward]"
			.."label[0.5,2.2;%.2f N•m right]"
			.."label[0.5,1.9;%.2f N•m left]"
			.."label[0.5,2.5;%.2f N•m up]"
			.."label[0.5,2.8;%.2f N•m down]"
			, power
			, speed
			, input_torque
			, oforward_torque
			, oright_torque
			, oleft_torque
			, oup_torque
			, odown_torque
			)
		)
	meta:set_string("infotext", string.format("Splitter %.1f rps, %.0f Wt", speed, power))
end

local function splitter_cb(pos, node, def, speed, dir)
	local tripod = rotary.facedir_to_tripod_gbox(node.param2)
	if not vector.equals(dir, tripod.w) then
		return nil -- incorrect input direction
	end
	local meta = minetest.get_meta(pos)
	local output_dir = { tripod.w, tripod.u, tripod.u.n, tripod.v, tripod.v.n }
	local output_torque = {}
	local torque = 0
	for i, dir in ipairs(output_dir) do
		local cpos, cnode, cdef = rotary.get_consumer(pos, dir)
		local torque1 = cdef and cdef.rotary.passive(cpos, cnode, cdef, speed, dir) or 0
		output_torque[i] = torque1
		torque = torque + torque1
	end
	splitter_update_info(meta, speed, torque, unpack(output_torque))
	return torque
end

minetest.register_node("rotary:splitter", {
	description = "Frictionless Splitter",
	tiles = {
		"default_bronze_block.png",
		"default_copper_block.png",
		"default_bronze_block.png",
		"default_bronze_block.png",
		"default_bronze_block.png",
		"default_bronze_block.png",
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
			{-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
			{-0.5, -0.1, -0.1, 0.5, 0.1, 0.1},
			{-0.1, -0.5, -0.1, 0.1, 0.5, 0.1},
			{-0.1, -0.1, -0.5, 0.1, 0.1, 0.5},
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
