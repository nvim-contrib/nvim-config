return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"nvim-contrib/nvim-snippets",
		},
		config = function(plugin, opts)
			require("astronvim.plugins.configs.luasnip")(plugin, opts)

			local snip = require("luasnip")
			-- Store selection on Ctrl+Y
			snip.setup({
				store_selection_keys = "<C-y>",
			})

			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})
			require("luasnip.loaders.from_vscode").lazy_load({
				paths = { vim.fn.stdpath("data") .. "/lazy/nvim-snippets" },
			})
		end,
	},
}
