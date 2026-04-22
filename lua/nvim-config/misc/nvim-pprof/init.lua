---@type LazySpec
return {
	"nvim-contrib/nvim-pprof",
	event = "User AstroFile",
	opts = {
		auto_reload = { enabled = true },
	},
	dependencies = {
		{
			"AstroNvim/astroui",
			opts = {
				icons = {
					PProf = "",
				},
			},
		},
		{
			"nvim-neotest/neotest",
			optional = true,
			opts = function(_, opts)
				opts.consumers = opts.consumers or {}
				opts.consumers.pprof = require("pprof.neotest")
			end,
		},
		{
			"AstroNvim/astrocore",
			optional = true,
			opts = function(_, opts)
				local astroui = require("astroui")
				local maps = opts.mappings

				local pprofile_prefix = "<Leader>P"

				maps.n[pprofile_prefix] = { desc = astroui.get_icon("PProf", 1, true) .. "PProf" }
				maps.n[pprofile_prefix .. "l"] = {
					function()
						require("pprof").load()
					end,
					desc = "Load pprof profile",
				}
				maps.n[pprofile_prefix .. "s"] = {
					function()
						require("pprof").toggle_line_signs()
					end,
					desc = "Toggle line signs",
				}
				maps.n[pprofile_prefix .. "t"] = {
					function()
						require("pprof").top()
					end,
					desc = "Show pprof top funcs",
				}
				maps.n[pprofile_prefix .. "p"] = {
					function()
						require("pprof").peek()
					end,
					desc = "Peek pprof func",
				}
				maps.n[pprofile_prefix .. "h"] = {
					function()
						require("pprof").toggle_line_hints()
					end,
					desc = "Toggle line hints",
				}
				maps.n[pprofile_prefix .. "o"] = {
					function()
						require("pprof").start_server()
					end,
					desc = "Start pprof server",
				}
				maps.n[pprofile_prefix .. "O"] = {
					function()
						require("pprof").stop_server()
					end,
					desc = "Stop pprof server",
				}
				maps.n[pprofile_prefix .. "c"] = {
					function()
						require("pprof").clear()
					end,
					desc = "Clear pprof",
				}
				maps.n[pprofile_prefix .. "e"] = {
					function()
						vim.g.pprof_collection_enabled = not vim.g.pprof_collection_enabled
						vim.notify(
							"Pprof collection " .. (vim.g.pprof_collection_enabled and "enabled" or "disabled"),
							vim.log.levels.INFO
						)
					end,
					desc = "Toggle pprof collection",
				}

				-- Sign navigation (] / [ convention)
				maps.n["]P"] = {
					function()
						require("pprof").jump_next()
					end,
					desc = "Next pprof line",
				}
				maps.n["[P"] = {
					function()
						require("pprof").jump_prev()
					end,
					desc = "Prev pprof line",
				}
			end,
		},
	},
}
