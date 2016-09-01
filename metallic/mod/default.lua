-- This file is part of the steam/metallic Minetest mod

metallic.import_metal("default:iron", {
	name = "Iron",
	color = "#aa9",
	ore_color = "#a95230",
	import = {
		ingot = "default:steel_ingot",
		block = "default:steel_block",
	},
})

metallic.import_metal("default:copper", {
	name = "Copper",
	color = "#e93",
})

metallic.import_metal("default:gold", {
	name = "Gold",
	color = "#eb0",
})

metallic.import_metal("default:bronze", {
	name = "Bronze",
	color = "#c60",
	import = {
		ore = false,
	},
})

metallic.import_material("default:wood", {
	name = "Wood",
	color = "#420",
	kind = "wood",
	import = {
		trunk = "default:trunk",
		planks = "default:wood",
	},
})

metallic.import_material("default:mese", {
	name = "Mese",
	color = "#ef0",
	kind = "special",
	import = {
		shard = "default:mese_shard",
		crystal = "default:mese",
		block = "default:mese_block",
	},
})

metallic.import_material("default:diamond", {
	name = "Diamond",
	color = "#0ef",
	kind = "special",
	import = {
		crystal = "default:diamond",
		block = "default:diamond_block",
	},
})

metallic.import_material("default:obsidian", {
	name = "Obsidian",
	color = "#112",
	kind = "special",
	import = {
		crystal = "default:obsidian_shard",
		block = "default:obsidian",
	},
})
