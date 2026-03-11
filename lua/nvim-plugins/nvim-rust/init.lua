---@type LazySpec
return {
	"nvim-neotest/neotest",
	optional = true,
	opts = function(_, opts)
		if not opts.adapters then
			return {}
		end

		local has_coverage, _ = pcall(require, "coverage.config")
		if not has_coverage then
			return opts
		end

		-- cache nightly detection — rustc --version is instant, no network calls
		local is_nightly = vim.fn.system("rustc --version 2>/dev/null"):match("nightly") ~= nil

		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "rustaceanvim" then
				local build_spec_base = adapter.build_spec
				adapter.build_spec = function(args)
					local spec = build_spec_base(args)
					if spec then
						local cmd = spec.command
						if cmd[1] == "cargo" then
							local lcov_path = vim.fn.getcwd() .. "/target/lcov.info"
							local extra = { "llvm-cov", "--lcov" }
							if is_nightly then table.insert(extra, "--branch") end
							table.insert(extra, "--output-path")
							table.insert(extra, lcov_path)
							for j = #extra, 1, -1 do
								table.insert(cmd, 2, extra[j])
							end
						end
					end
					return spec
				end
				break
			end
		end
		return opts
	end,
}
