--- Check whether a directory is a Ginkgo suite (has suite_test.go).
local function is_ginkgo_suite(name, rel_path, root)
	local dir = root .. "/" .. rel_path
	return vim.fn.filereadable(dir .. "/suite_test.go") == 1
		or vim.fn.filereadable(dir .. "/" .. name .. "_suite_test.go") == 1
end

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-contrib/neotest-ginkgo",
	},
	optional = true,
	opts = function(_, opts)
		if not opts.adapters then
			opts.adapters = {}
		end

		-- Patch neotest-golang/neotest-go to skip Ginkgo suite directories.
		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "neotest-golang" or adapter.name == "neotest-go" then
				local original_filter_dir = adapter.filter_dir
				adapter.filter_dir = function(name, rel_path, root)
					if is_ginkgo_suite(name, rel_path, root) then
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
			table.insert(ginkgo_opts.command, "--output-dir=" .. vim.fn.getcwd())

			opts.consumers = opts.consumers or {}
			opts.consumers.coverage_go = require("coverage.neotest.go")
		end

		table.insert(opts.adapters, ginkgo_adapter.setup(ginkgo_opts))
	end,
}
