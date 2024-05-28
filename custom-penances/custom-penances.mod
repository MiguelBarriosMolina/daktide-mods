return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`custom-penances` encountered an error loading the Darktide Mod Framework.")

		new_mod("custom-penances", {
			mod_script       = "custom-penances/scripts/mods/custom-penances/custom-penances",
			mod_data         = "custom-penances/scripts/mods/custom-penances/custom-penances_data",
			mod_localization = "custom-penances/scripts/mods/custom-penances/custom-penances_localization",
		})
	end,
	packages = {},
}
