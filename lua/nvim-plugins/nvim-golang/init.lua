return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-contrib/nvim-ginkgo",
	},
	optional = true,
	opts = function(_, opts)
		if not opts.adapters then
			opts.adapters = {}
		end

		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "neotest-golang" or adapter.name == "neotest-go" then
				local original_filter_dir = adapter.filter_dir
				---Filter directories when searching for test files
				---@async
				---@param name string Name of directory
				---@param rel_path string Path to directory, relative to root
				---@param root string Root directory of project
				---@return boolean
				adapter.filter_dir = function(name, rel_path, root)
					local dir = root .. "/" .. rel_path
					if
							vim.fn.filereadable(dir .. "/suite_test.go") == 1
							or vim.fn.filereadable(dir .. "/" .. name .. "_suite_test.go") == 1
					then
						return false
					end
					if original_filter_dir then
						return original_filter_dir(name, rel_path, root)
					end

					return true
				end
			end
		end

		local core = require("astrocore")
		local ginkgo_opts = core.plugin_opts("nvim-ginkgo")
		local ginkgo_adapter = require("nvim-ginkgo")

		-- enable coverage flags when nvim-coverage is available
		local has_coverage, _ = pcall(require, "coverage.config")
		if has_coverage then
			if not ginkgo_opts.command then
				ginkgo_opts.command = { "ginkgo", "run", "-v" }
			end
			table.insert(ginkgo_opts.command, "-cover")
			table.insert(ginkgo_opts.command, "-coverprofile=coverage.out")

			-- after tests finish, convert coverage.out → coverage/lcov.info
			opts.consumers = opts.consumers or {}
			opts.consumers.coverage_go = function(client)
				client.listeners.results = function(_, _, partial)
					if partial then return end
					local cwd = vim.fn.getcwd()
					local coverprofile = cwd .. "/coverage.out"
					local lcov_out = cwd .. "/coverage/lcov.info"
					if vim.fn.filereadable(coverprofile) == 1 then
						vim.fn.mkdir(cwd .. "/coverage", "p")
						vim.fn.jobstart({
							"go", "tool", "cover",
							"-o", lcov_out,
							coverprofile,
						}, {
							on_exit = function(_, code)
								if code == 0 then
									vim.schedule(function()
										require("coverage").load(lcov_out, require("coverage.signs").is_enabled())
									end)
								end
							end,
						})
					end
				end
				return {}
			end
		end

		table.insert(opts.adapters, ginkgo_adapter.setup(ginkgo_opts))
	end,
}
