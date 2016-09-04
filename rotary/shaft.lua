-- This file is part of the steam/rotary Minetest mod

local function shaft_cb(pos, node, def, speed, dir)
	local tripod = rotary.facedir_to_tripod_gbox(node.param2)
	if not vector.equals(dir, tripod.w) then
		return 0, 0 -- incorrect input direction
	end
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.w)
	local torque, inertia = 0, 0
	if cdef then
		torque, inertia = cdef.rotary.passive(cpos, cnode, cdef, speed, tripod.w)
	end
	return torque + 0.2, inertia + 0.02
end

minetest.register_node("rotary:shaft", {
	description = "Shaft",
	tiles = {
		"rotary_dark_iron_half_block.png^rotary_output.png",
		"rotary_dark_iron_half_block.png^rotary_input.png",
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png",
		"rotary_dark_iron_block.png",
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
			rotary.nodebox.shaft_w,
		},
	},
	sunlight_propagates = true,
	on_construct = function(pos)
		rotary.init_gbox_facedir(pos)
	end,
	rotary = {
		passive = shaft_cb,
	},
})
