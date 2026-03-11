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

		--- Returns true when branch coverage should be enabled.
		--- Checks (in order):
		---   1. CARGO_LLVM_COV_BRANCH=0  → always disabled
		---   2. CARGO_LLVM_COV_BRANCH=1  → always enabled
		---   3. rust-toolchain.toml / rust-toolchain file contains "nightly"
		---   4. RUSTUP_TOOLCHAIN env var contains "nightly"
		local function branch_enabled(cwd)
			local env = vim.fn.getenv("CARGO_LLVM_COV_BRANCH")
			if env ~= vim.NIL then
				return tostring(env) ~= "0"
			end
			for _, fname in ipairs({ "rust-toolchain.toml", "rust-toolchain" }) do
				local path = cwd .. "/" .. fname
				if vim.fn.filereadable(path) == 1 then
					for _, line in ipairs(vim.fn.readfile(path)) do
						if line:match("nightly") then return true end
					end
					return false -- toolchain file found but no nightly
				end
			end
			local rustup = vim.fn.getenv("RUSTUP_TOOLCHAIN")
			return rustup ~= vim.NIL and tostring(rustup):match("nightly") ~= nil
		end

		for _, adapter in ipairs(opts.adapters) do
			if adapter.name == "rustaceanvim" then
				local build_spec_base = adapter.build_spec
				adapter.build_spec = function(args)
					local spec = build_spec_base(args)
					if spec then
						local cmd = spec.command
						if cmd[1] == "cargo" then
							local cwd = vim.fn.getcwd()
							local lcov_path = cwd .. "/target/lcov.info"
							local extra = { "llvm-cov", "--lcov" }
							if branch_enabled(cwd) then table.insert(extra, "--branch") end
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
