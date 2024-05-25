local mod = get_mod("show-current-penance-stat")
local achievement_manager = Managers.achievements
local _grouped_penances = {
    group_flawless_mission = {"flawless_mission_1","flawless_mission_2","flawless_mission_3"},
    group_untouchable_operative = {"personal_mission_auric_flawless_1", "personal_mission_auric_flawless_2"}}

local switch_prefer_running_flag = function(definitions_file, penance_name, flag)
    if(definitions_file[penance_name]) then
        if(definitions_file[penance_name].flags == nil) then
            definitions_file[penance_name].flags = {}
        end
        definitions_file[penance_name].flags["prioritize_running"] = flag
    end
end

local switch_group_prefer_running_flag = function(definitions_file, group_name, flag)
    local group = _grouped_penances[group_name]
    for index, penance in pairs(group) do
        switch_prefer_running_flag(definitions_file, penance, flag)
    end
end


mod:hook_require("scripts/managers/achievements/achievement_definitions", function(instance)
        mod.on_setting_changed = function(setting_id)
            local flag = mod:get(setting_id)
            local penance_name = string.sub(setting_id, 8)
            if(_grouped_penances[penance_name] ~= nil) then
                for index, sub_penance_name in pairs(_grouped_penances[penance_name]) do
                    switch_prefer_running_flag(instance, sub_penance_name, flag)
                    achievement_manager._definitions[sub_penance_name] = instance[sub_penance_name]
                end
            else
                achievement_manager._definitions[penance_name] = instance[penance_name]
            end
        end

        switch_group_prefer_running_flag(instance, "group_untouchable_operative", mod:get("toggle_group_untouchable_operative"))
        switch_group_prefer_running_flag(instance, "group_flawless_mission", mod:get("toggle_group_flawless_mission"))
        switch_prefer_running_flag(instance, "flawless_auric_maelstrom_consecutive", mod:get("toggle_flawless_auric_maelstrom_consecutive"))
    end
)


