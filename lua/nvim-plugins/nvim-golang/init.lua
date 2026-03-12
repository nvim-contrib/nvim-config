--- Check whether a directory is a Ginkgo suite (has suite_test.go).
local function is_ginkgo_suite(name, rel_path, root)
	local dir = root .. "/" .. rel_path
	return vim.fn.filereadable(dir .. "/suite_test.go") == 1
		or vim.fn.filereadable(dir .. "/" .. name .. "_suite_test.go") == 1
end

--- Neotest consumer that finds coverage.out written by ginkgo anywhere
--- in the project tree and loads it into nvim-coverage.
local function ginkgo_coverage_consumer(client)
	client.listeners.results = function(adapter_id, _, partial)
		if partial or adapter_id ~= "neotest-ginkgo" then
			return
		end

		local cwd = vim.fn.getcwd()
		local files = vim.fn.glob(cwd .. "/**/coverage.out", false, true)
		if #files == 0 then
			return
		end

		-- Use the most recently modified coverage.out
		table.sort(files, function(a, b)
			return vim.fn.getftime(a) > vim.fn.getftime(b)
		end)

		local coverprofile = files[1]
		local lcov_out = cwd .. "/coverage/lcov.info"
		vim.fn.mkdir(cwd .. "/coverage", "p")
		vim.fn.jobstart({ "go", "tool", "cover", "-o", lcov_out, coverprofile }, {
			on_exit = function(_, code)
				if code == 0 then
					vim.schedule(function()
						require("coverage").load(lcov_out, require("coverage.signs").is_enabled())
					end)
				end
			end,
		})
	end
	return {}
end

return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-contrib/neotest-ginkgo",
		},
		optional = true,
		opts = function(_, opts)
			if not opts.adapters then
				opts.adapters = {}
			end

			-- Patch neotest-golang to skip Ginkgo suite directories.
			-- User opts run after astrocommunity opts, so the adapter
			-- is already in the list at this point.
			for _, adapter in ipairs(opts.adapters) do
				if adapter.name == "neotest-golang" or adapter.name == "neotest-go" then
					local original_filter_dir = adapter.filter_dir
					adapter.filter_dir = function(name, rel_path, root)
						if is_ginkgo_suite(name, rel_path, root) then
							return false
						end
						return original_filter_dir(name, rel_path, root)
					end
				end
			end

			local core = require("astrocore")
			local ginkgo_opts = core.plugin_opts("neotest-ginkgo")
			local ginkgo_adapter = require("neotest-ginkgo")

			-- enable coverage flags when nvim-coverage is available
			local has_coverage, _ = pcall(require, "coverage.config")
			if has_coverage then
				if not ginkgo_opts.command then
					ginkgo_opts.command = { "ginkgo", "run", "-v" }
				end
				table.insert(ginkgo_opts.command, "-cover")
				table.insert(ginkgo_opts.command, "-coverprofile=coverage.out")

				opts.consumers = opts.consumers or {}
				opts.consumers.ginkgo_coverage = ginkgo_coverage_consumer
			end

			table.insert(opts.adapters, ginkgo_adapter.setup(ginkgo_opts))
		end,
	},
}
