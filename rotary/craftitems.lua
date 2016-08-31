-- This file is part of the steam/rotary Minetest mod

local metal = {}

local item_size = {
	"Small",
	"Medium",
	"Large",
}

local register_metal, register_gears;

local function process_name(name)
	local override, modname, basename = string.match(name, "^(:?)([a-zA-Z0-9_]+):([a-zA-Z0-9_]+)$")
	if basename then
		if override ~= ":" and modname ~= minetest.get_current_modname() then
			error(string.format("Attempt to register %s:%s from mod %s (use :mod:item to override)", modname, basename, minetest.get_current_modname()))
		end
		return modname..":"..basename, override..modname..":"..basename, modname.."_"..basename
	end
end

function register_metal(name, def)
	local cname, rname, tname = process_name(name)
	local longname = def.description or cname
	local color1 = def.color or "#F0F"
	local color2 = def.ore_color or "#310"
-- Ingot
-- Ore
	if def.ore ~= false then
-- Lump
		if type(def.ore) ~= "string" then
			minetest.log("info", "Registering ore for " .. cname)
			local orename = string.format("%s_ore", rname)
			local oredef = def.ore or {
				description = string.format("%s Ore", longname),
				inventory_image = string.format("%s_ore.png", tname),
			}
			minetest.register_craftitem(orename, oredef)
			def.ore = orename
		end
-- Processed ore
		minetest.register_craftitem(string.format("%s_crushed_ore", rname), {
			description = string.format("Crushed %s Ore", longname),
			inventory_image = string.format("rotary_crushed_ore_light_1.png^[colorize:%s:150^(rotary_crushed_ore_light_2.png^[colorize:%s:200)", color1, color2),
		})
	end
-- Metal dust
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_dust%d", rname, id), {
			description = string.format("%s Pile of %s Dust", size, longname),
			inventory_image = string.format("rotary_dust%d_light.png^[colorize:%s:110", id, color1, id),
		})
	end
	minetest.register_craft{type = "shapeless", output = cname.."_dust1 2", recipe = {cname.."_dust2"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust2 2", recipe = {cname.."_dust3"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust2", recipe = {cname.."_dust1", cname.."_dust1"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust3", recipe = {cname.."_dust2", cname.."_dust2"}}
	minetest.register_craft{type = "shapeless", output = cname.."_dust3", recipe = {cname.."_dust1", cname.."_dust1", cname.."_dust1", cname.."_dust1"}}
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_fine_powder%d", rname, id), {
			description = string.format("%s Pile of Fine %s Powder", size, longname),
			inventory_image = string.format("rotary_dust%d_light.png^[colorize:%s:190", id, color1, id),
		})
	end
	-- no mixing! use precision balance
-- Plates
-- Gears
	if def.machinery ~= false then
		register_gears(name, longname, color1)
	end
end

function register_gears(name, longname, color)
	local cname, rname, tname = process_name(name)
	for id, size in ipairs(item_size) do
		minetest.register_craftitem(string.format("%s_gear%d", rname, id), {
			description = string.format("%s %s Gear", size, longname),
			inventory_image = string.format("rotary_gear%d_light.png^[colorize:%s:200", id, color),
		})
	end
end

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

register_gears("rotary:wood", "Wooden", "#420")
register_gears("rotary:mese", "Mese", "#ef0")
