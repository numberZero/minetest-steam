-- This file is part of the steam/metallic Minetest mod

local SUPPORTED_MODS = {
	"default",
	"moreores",
	"technic_worldgen",
}

local path = minetest.get_modpath("metallic")

metallic = {}
metallic.materials = {}
metallic.items = {}

local function import_material(cname, desc)
	print("Importing " .. dump(cname) .. ": " .. dump(desc))
	if metallic.materials[cname] then
		error("Can’t import material: already imported: " .. cname)
	end
	local material = {}
	material.name = desc.name
	material.color = desc.colors and desc.colors[1] or desc.color or "#F0F"
	material.colors = desc.colors or { material.color }
	material.kind = desc.kind
	material.forms = {}
	for form, item in pairs(desc.import) do
		material.forms[form] = item
		metallic.items[item] = {
			cname = cname,
			form = form,
		}
	end
	metallic.materials[cname] = material
	return material
end

local metal_default_imports = {
	ore = "%s_lump",
	ingot = "%s_ingot",
	block = "%s_block",
}

local function import_metal(cname, desc)
	desc.kind = "metal"
	desc.colors = { desc.color, desc.ore_color }
	if not desc.import then
		desc.import = {}
	end
	for form, item in pairs(metal_default_imports) do
		if desc.import[form] == false then
			desc.import[form] = nil
		elseif desc.import[form] == true or desc.import[form] == nil then
			desc.import[form] = metal_default_imports[form]:format(cname)
		end
	end
	return metallic.import_material(cname, desc)
end

metallic.import_material = setmetatable({
	hooks = {},
	add_hook = function(self, hook, catchup)
		table.insert(self.hooks, hook)
		if catchup == false then
			return
		end
		for cname, material in pairs(metallic.materials) do
			hook(cname, material)
		end
	end,
}, {
	__call = function(self, cname, ...)
		local material = import_material(cname, ...)
		for _, hook in ipairs(self.hooks) do
			hook(cname, material)
		end
		return material
	end,
})

metallic.import_metal = import_metal

for _, name in ipairs(SUPPORTED_MODS) do
	if minetest.get_modpath(name) then
		dofile(path.."/mod/"..name..".lua")
	end
end

return metallic
