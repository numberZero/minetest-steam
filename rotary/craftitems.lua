-- This file is part of the steam/rotary Minetest mod

local item_size = {
	"Small",
	"Medium",
	"Large",
}

local function get_local_name(cname)
	return string.format("rotary:%s_%s", unpack(string.split(cname, ":")))
end

local function on_add_material(cname, material)
	if material.kind ~= "metal" then
		return
	end
	local localname = get_local_name(cname)
	local longname = material.name or cname
	local color1 = material.colors[1] or "#F0F"
	local color2 = material.colors[2] or "#310"
-- Crushed metal
	minetest.register_craftitem(string.format("%s_crushed", localname), {
		description = string.format("Crushed %s", longname),
		inventory_image = string.format("rotary_crushed_ore_light_1.png^[colorize:%s:100^(rotary_crushed_ore_light_2.png^[colorize:%s:150)", color1, color1),
	})
-- Processed ore
	if material.forms.ore then
		minetest.register_craftitem(string.format("%s_crushed_ore", localname), {
			description = string.format("Crushed %s Ore", longname),
			inventory_image = string.format("rotary_crushed_ore_light_1.png^[colorize:%s:150^(rotary_crushed_ore_light_2.png^[colorize:%s:200)", color1, color2),
		})
	end
-- Metal dust
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_dust%d", localname, id), {
			description = string.format("%s Pile of %s Dust", size, longname),
			inventory_image = string.format("rotary_dust%d_light.png^[colorize:%s:110", id, color1, id),
		})
	end
	minetest.register_craft{type = "shapeless", output = localname.."_dust1 2", recipe = {localname.."_dust2"}}
	minetest.register_craft{type = "shapeless", output = localname.."_dust2 2", recipe = {localname.."_dust3"}}
	minetest.register_craft{type = "shapeless", output = localname.."_dust2", recipe = {localname.."_dust1", localname.."_dust1"}}
	minetest.register_craft{type = "shapeless", output = localname.."_dust3", recipe = {localname.."_dust2", localname.."_dust2"}}
	minetest.register_craft{type = "shapeless", output = localname.."_dust3", recipe = {localname.."_dust1", localname.."_dust1", localname.."_dust1", localname.."_dust1"}}
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_fine_powder%d", localname, id), {
			description = string.format("%s Pile of Fine %s Powder", size, longname),
			inventory_image = string.format("rotary_dust%d_light.png^[colorize:%s:190", id, color1, id),
		})
	end
	-- no mixing! use precision balance
-- Plates
	minetest.register_craftitem(string.format("%s_plate", localname), {
		description = string.format("%s Plate", longname),
		inventory_image = string.format("rotary_plate_light.png^[colorize:%s:200", color1),
	})
-- Gears
	register_gears(cname)
end

function register_gears(cname)
	local localname = get_local_name(cname)
	local material = metallic.materials[cname]
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_gear%d", localname, id), {
			description = string.format("%s %s Gear", size, material.name),
			inventory_image = string.format("rotary_gear%d_light.png^[colorize:%s:200", id, material.color),
		})
	end
end

--[[
register_metal("rotary:dark_iron", {
	description = "Dark Iron",
	color = "#3c3450",
	ore = false,
})

register_metal("rotary:iron", {
	description = "Iron",
	color = "#aa9",
	ore_color = "#a95230",
	ore = "default:iron_lump",
})

register_metal("rotary:copper", {
	description = "Copper",
	color = "#e93",
	ore = "default:copper_lump",
	machinery = false,
})

register_metal("rotary:gold", {
	description = "Gold",
	color = "#eb0",
	ore = "default:gold_lump",
	machinery = false,
})

register_metal("rotary:bronze", {
	description = "Bronze",
	color = "#c60",
	ore = false,
})
]]

metallic.import_material:add_hook(on_add_material)

register_gears("default:wood")
register_gears("default:mese")
