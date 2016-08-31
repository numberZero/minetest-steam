-- This file is part of the steam/rotary Minetest mod

local metal = {}

local item_size = {
	"Small",
	"Medium",
	"Large",
}

local function process_name(name)
	local override, modname, basename = string.match(name, "^(:?)([a-zA-Z0-9_]+):([a-zA-Z0-9_]+)$")
	if basename then
		if override ~= ":" and modname ~= minetest.get_current_modname() then
			error(string.format("Attempt to register metal %s:%s from mod %s (use :mod:item to override)", modname, basename, minetest.get_current_modname()))
		end
		return modname..":"..basename, override..modname..":"..basename, modname, basename
	end
end

local function register_metal(name, def)
	local cname, rname = process_name(name)
	local longname = def.description or cname
	local color1 = def.color or "#F0F"
	local color2 = def.ore_color or "#310"
-- Lump
-- Ingot
-- Processed ore
	minetest.register_craftitem(string.format("%s_crushed_ore", rname), {
		description = string.format("Crushed %s Ore", longname),
		inventory_image = string.format("rotary_crushed_ore_light_1.png^[colorize:%s:150^(rotary_crushed_ore_light_2.png^[colorize:%s:200)", color1, color2),
	})
-- Metal dust
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_dust%d", rname, id), {
			description = string.format("%s Pile of %s Dust", size, longname),
			inventory_image = string.format("rotary_dust%d_light.png^[colorize:%s:200", id, color1),
		})
	end
	minetest.register_craft{type = "shapeless", output = cname.."_dust1 2", recipe = {cname.."_dust2"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust2 2", recipe = {cname.."_dust3"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust2", recipe = {cname.."_dust1", cname.."_dust1"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust3", recipe = {cname.."_dust2", cname.."_dust2"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust3", recipe = {cname.."_dust1", cname.."_dust1", cname.."_dust1", cname.."_dust1"}}
-- Plates
-- Gears
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_gear%d", rname, id), {
			description = string.format("%s %s Gear", size, longname),
			inventory_image = string.format("rotary_gear%d_light.png^[colorize:%s:200", id, color1),
		})
	end
end

register_metal("rotary:dark_iron", {
	description = "Dark Iron",
	color = "#3c3450",
})

register_metal(":default:iron", {
	description = "Iron",
	color = "#eeeeee",
	ore_color = "#a95230",
})

register_metal(":default:copper", {
	description = "Copper",
	color = "#ee9933",
})
