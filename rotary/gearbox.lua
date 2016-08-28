-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- @function gearbox_update_info
-- @param core#NodeMetaRef	meta
-- @param #number rate
-- @param #number input_speed
-- @param #number input_torque
-- @param #number output_speed
-- @param #number output_torque
local function gearbox_update_info(meta, rate, input_speed, input_torque, output_speed, output_torque)
	local power = input_speed * input_torque
	meta:set_string("formspec",
		"size[4,2]"
		.."label[1.0,0.0;Gearbox]"
		.."label[0.0,0.4;Rate: "..rate.."]"
		.."label[0.0,0.7;Power: "..power.." Wt]"
		.."label[0.0,1.0;Input: "..input_torque.." N*m at "..input_speed.." s^-1]"
		.."label[0.0,1.3;Output: "..output_torque.." N*m at "..output_speed.." s^-1]"
		)
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
	local tripod = rotary.facedir_to_tripod(node.param2)
	if not vector.equals(dir, tripod.u) then
		return nil -- incorrect input direction
	end
	local meta = minetest.get_meta(pos)
	local rate = meta:get_float("rate") or 1
	local cpos, cnode, cdef = rotary.get_consumer(pos, tripod.u)
	local output_speed = speed * rate
	local output_torque = cdef and cdef.rotary.passive(cpos, cnode, cdef, output_speed, tripod.u) or 0
	local torque = output_torque * rate
	gearbox_update_info(meta, rate, speed, torque, output_speed, output_torque)
	return torque
end

minetest.register_node("rotary:gearbox", {
	description = "Gearbox",
	tiles = {
		"default_steel_block.png",
		"default_steel_block.png",
		"default_bronze_block.png",
		"default_copper_block.png",
		"default_steel_block.png",
		"default_steel_block.png"
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
		},
	},
	sunlight_propagates = true,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_float("rate", 2.0)
		gearbox_update_info(meta, 2.0, 0, 0, 0, 0)
	end,
--	on_receive_fields = function(pos, formname, fields, sender)
--	end,
	rotary = {
		passive = gearbox_cb,
	},
})
