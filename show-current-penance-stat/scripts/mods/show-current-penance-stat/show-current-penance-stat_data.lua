local mod = get_mod("show-current-penance-stat")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{ setting_id = "toggle_group_flawless_mission",
			type = "checkbox",
			default_value = true },
			{ setting_id = "toggle_flawless_auric_maelstrom_consecutive",
			type = "checkbox",
			default_value = true },
			{ setting_id = "toggle_group_untouchable_operative",
			type = "checkbox",
			default_value = true }
		}
	}
}
