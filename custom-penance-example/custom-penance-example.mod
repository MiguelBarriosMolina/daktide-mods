return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`custom-penance-example` encountered an error loading the Darktide Mod Framework.")

		new_mod("custom-penance-example", {
			mod_script       = "custom-penance-example/scripts/mods/custom-penance-example/custom-penance-example",
			mod_data         = "custom-penance-example/scripts/mods/custom-penance-example/custom-penance-example_data",
			mod_localization = "custom-penance-example/scripts/mods/custom-penance-example/custom-penance-example_localization",
		})
	end,
	packages = {},
}
