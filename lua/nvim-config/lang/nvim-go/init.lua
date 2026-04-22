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

			local has_coverage, _ = pcall(require, "coverage.config")
			local has_pprof, _ = pcall(require, "pprof.config")

			if has_coverage then
				opts.consumers = opts.consumers or {}
				opts.consumers.coverage_go = require("coverage.neotest.go")
			end

			if has_pprof then
				opts.consumers = opts.consumers or {}
				opts.consumers.pprof_go = require("pprof.neotest.go")
			end

			local adapter = ginkgo_adapter.setup(ginkgo_opts)
			local original_build_spec = adapter.build_spec

			-- inject coverage/pprof flags at run time so toggles take effect without restart
			adapter.build_spec = function(args)
				local extra = vim.list_extend({}, args and args.extra_args or {})
				if has_coverage and vim.g.coverage_collection_enabled == true then
					vim.list_extend(extra, { "--cover", "--coverprofile=coverage.out" })
				end
				if has_pprof and vim.g.pprof_collection_enabled == true then
					vim.list_extend(extra, { "--cpuprofile=cpu.pprof", "--memprofile=mem.pprof" })
				end
				return original_build_spec(vim.tbl_extend("force", args or {}, { extra_args = extra }))
			end

			table.insert(opts.adapters, adapter)
		end,
	},
}
