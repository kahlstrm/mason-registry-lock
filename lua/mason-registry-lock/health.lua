local health = vim.health or require("health")

local M = {}

function M.check()
	health.start("Mason Registry Lock")

	local ok, registry_lock = pcall(require, "mason-registry-lock")
	if not ok then
		health.error("Failed to load mason-registry-lock module")
		return
	end

	if registry_lock.registry_release then
		health.ok("Registry release: " .. registry_lock.registry_release)

		if registry_lock.registry_release:match("^github:mason%-org/mason%-registry@") then
			health.ok("Registry release format is correct")
		else
			health.warn("Registry release format may be incorrect (expected github:mason-org/mason-registry@<tag>)")
		end
	else
		health.error("No registry_release found in module")
	end

	local mason_ok, mason = pcall(require, "mason")
	if mason_ok then
		health.ok("Mason is available")
	else
		health.warn("Mason is not installed or not available")
	end
end

return M

