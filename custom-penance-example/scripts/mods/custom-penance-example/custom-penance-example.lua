local mod = get_mod("custom-penance-example")
local custom_penances = get_mod("custom-penances")

-- Define our localizations
mod:add_global_localize_strings({
    loc_custom_penance_mutie_throw_distance_title= {
        en = "Weeeeeee"
    },
    loc_custom_penance_mutie_throw_distance_description = {
        en = "Move 10 meters by getting thrown by muties"
    },
    loc_inserted_custom_penance = {
        en = "Other mod penances"
    }
})

-- Define our penance
local custom_penance_mutie_throw_distance = {
        id = "custom_penance_mutie_throw_distance", -- Must be unique
        description = "loc_custom_penance_mutie_throw_distance_description",
        title = "loc_custom_penance_mutie_throw_distance_title",
        icon = "content/ui/textures/icons/achievements/achievement_icon_0135",
        target = 10, -- The value we need to hit to complete the penance. The completion bar is calculated using this and the progress
        category = "inserted_custom_penances_group", -- This is the tab or subgroup that our penance will appear in. By default, it will be placed in the custom penance tab. 
        flags = {"hide_from_carousel"}, -- Options here are "hide_progress", "allow_solo", "private_only", "hide_missing", "hide_from_carousel", "prioritize_running". These are defaul game flags, not used by the custom penance mod
        initial_completion = false, -- If we want this penance to complete as soon as possible, usually on loading into the mourningstar
        initial_progress = 0, -- If you want the penance to start with some progress already done 
    }

-- OPTIONAL: Create a group for our penances in the custom penances tab
custom_penances.create_penance_group({name="inserted_custom_penances_group", display_name="loc_inserted_custom_penance"})

-- Pass our penance definition to custom penance manager
custom_penances.add_penance(custom_penance_mutie_throw_distance)


-- Create hooks to handle our penance proression
local player_manager = Managers.player
local local_player = nil
local player_loaded = function()
    if(local_player == nil) then
        local_player = player_manager:local_player(1)
    end
    return local_player ~= nil
end

local start_position = {}


mod:hook_safe(CLASS.PlayerCharacterStateMutantCharged, "on_enter", function(self, unit)
    if(player_loaded() and player_manager:player_by_unit(unit) == local_player) then
        local local_position = Unit.local_position(unit, 1)
        start_position.x, start_position.y = local_position.x, local_position.y
    end
end)

mod:hook_safe(CLASS.PlayerCharacterStateWalking, "on_enter", function(self, unit, dt, t, previous_state, params)
    local round = function(number)
        return math.floor(number+0.5)
    end
    if(previous_state == "mutant_charged" and player_loaded() and player_manager:player_by_unit(unit) == local_player) then
        local end_position = Unit.local_position(unit, 1)
        local distance_travelled = round(math.sqrt((round(start_position.x) - round(end_position.x))^2 + (round(start_position.y) - round(end_position.y))^2))
        if(distance_travelled < 50) then
            custom_penances.increase_progress("custom_penance_mutie_throw_distance", distance_travelled)
        end
    end
end)