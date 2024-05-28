
local CustomPenanceDefinitions = {
    custom_penance_overkill = {
        id = "custom_penance_overkill",
        description = "loc_custom_penance_overkill_description",
        title = "loc_custom_penance_overkill_title",
        icon = "content/ui/textures/icons/achievements/achievement_icon_0089",
        target = 1000000000000000,
        stat_name = "total_kills",
        type = "increasing_stat",
        category = "custom_group_1",
        flags = {"hide_from_carousel"},
        initial_completion = false,
        initial_progress = 0,
        index = 2
    },
    custom_penance_command_trigger = {
        id = "custom_penance_command_trigger",
        description = "loc_custom_penance_commands_description",
        title = "loc_custom_penance_commands_title",
        icon = "content/ui/textures/icons/achievements/achievement_icon_0069",
        type = "custom_achievement_type",
        category = "custom_group_1",
        flags = {"hide_progress", "hide_from_carousel"},
        initial_completion = false,
        initial_progress = 0,
        index = 1
    },
    custom_penance_install = {
        id = "custom_penance_install",
        description = "loc_custom_penance_install_description",
        title = "loc_custom_penance_install_title",
        icon = "content/ui/textures/icons/achievements/achievement_icon_0100",
        target = 1,
        type = "custom_achievement_type",
        category = "custom_group_1",
        flags = {"hide_progress", "hide_from_carousel"},
        initial_completion = true,
        initial_progress = 1,
        index = 0
    },
}

return CustomPenanceDefinitions