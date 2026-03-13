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

			-- Remove neotest-golang adapter — neotest-ginkgo handles Go tests
			for i = #opts.adapters, 1, -1 do
				local adapter = opts.adapters[i]
				if adapter.name == "neotest-golang" or adapter.name == "neotest-go" then
					table.remove(opts.adapters, i)
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
				opts.consumers.coverage_go = require("coverage.neotest.go")
			end

			table.insert(opts.adapters, ginkgo_adapter.setup(ginkgo_opts))
		end,
	},
}
