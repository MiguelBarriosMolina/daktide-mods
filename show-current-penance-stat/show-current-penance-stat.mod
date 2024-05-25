return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`show-current-penance-stat` encountered an error loading the Darktide Mod Framework.")

		new_mod("show-current-penance-stat", {
			mod_script       = "show-current-penance-stat/scripts/mods/show-current-penance-stat/show-current-penance-stat",
			mod_data         = "show-current-penance-stat/scripts/mods/show-current-penance-stat/show-current-penance-stat_data",
			mod_localization = "show-current-penance-stat/scripts/mods/show-current-penance-stat/show-current-penance-stat_localization",
		})
	end,
	packages = {},
}
