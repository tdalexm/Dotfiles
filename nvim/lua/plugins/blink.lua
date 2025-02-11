return {
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = {
			{ "saghen/blink.compat", lazy = true, version = "*" },
			"rafamadriz/friendly-snippets",
			"L3MON4D3/LuaSnip",
		},
		opts = {
			sources = {
				compat = { "obsidian", "obsidian_new", "obsidian_tags" },
			},
		},
	},
}
