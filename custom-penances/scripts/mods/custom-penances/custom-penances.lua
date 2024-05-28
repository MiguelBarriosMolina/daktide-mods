local mod = get_mod("custom-penances")

local CustomAchievementType = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/CustomAchievementType")
local CustomPenanceDefinitions = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/CustomPenanceDefinitions")
local CustomPenanceLocalization = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/CustomPenanceLocalization")
local CommandDefinitions = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/CommandDefinitions")
local CommandTemplate = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/CommandTemplate")
local PenanceStatusCache = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/PenanceStatusCache")
local achievement_manager = Managers.achievements


local CustomPenances = {}

-- ONGOING: Errors on save because the penance tables are not json compatible. Moving them to separate files to have an easier time when I have to fight through the hell
-- of converting from json with string keys to lua table with regular keys
-- Since I probably have to pass tables with key identifiers that are not strings to the darktide code

-- LOCAL DATA
local achievement_definitions_instance = {}
local achievement_categories_instance = {}
local last_category_sort_index = 0
local pending_penances_ids = {}
local we_are_in_game = false;


-- FUNCTIONS & UTILS
local update_achievement_manager_definition = function(penance)
    achievement_manager._definitions[penance.id] = penance
end

local create_penance_group = function(penance_group)
    penance_group.parent_name = "custom"
    last_category_sort_index = last_category_sort_index+1
    penance_group.sort_index = last_category_sort_index
    achievement_categories_instance[penance_group.name] = penance_group
end

local notify_completion = function(penance_id)
    local notified = PenanceStatusCache.was_notified(penance_id)
    if(not notified) then
        if(we_are_in_game) then
            Managers.event:trigger("event_add_notification_message", "achievement", CustomPenanceDefinitions[penance_id])
            PenanceStatusCache.set_notified(penance_id, true)
        else
            print("Could not notify about "..penance_id.." completion, saving it to pending")
            table.insert(pending_penances_ids, penance_id)
        end
    end
end

local complete_penance = function(penance_id)
    print("Completing penance "..penance_id)
    local penance = CustomPenanceDefinitions[penance_id]
    if(penance ~= nil and not PenanceStatusCache.is_complete(penance_id)) then
        PenanceStatusCache.set_complete(penance_id, true)
        update_achievement_manager_definition(penance)
        mod:echo("Successfully completed penance with id "..penance_id)
    else
       print("Could not complete penance with id "..penance_id..", not found or already completed")
    end
    notify_completion(penance_id)
end

local reset_complete_penance = function(penance_id)
    local penance = CustomPenanceDefinitions[penance_id]
    if(penance ~= nil) then
        PenanceStatusCache.set_complete(penance_id, false)
    else
       mod:echo("Completed penance with id "..penance_id.." not found")
    end
    mod:echo("Successfully reset penance with id "..penance_id)
end

local offset_penance = function(penance_id, offset)
    local penance = CustomPenanceDefinitions[penance_id]
    if(penance == nil) then
        mod:error("Custom penances error: Penance with id "..penance_id.." not found")
        return
    end
    if(penance.target == nil ) then
        mod:error("Custom penances error: Penance with id "..penance_id.." does not have a target to offset")
        return
    end
    if type(offset) ~="number" then
        mod:error("Custom penances error: Offset has to be a number, got a "..type(offset))
        return
    end

    penance.target = penance.target + offset
    PenanceStatusCache.set_target(penance_id, penance.target)

    local was_complete = PenanceStatusCache.is_complete(penance_id)
    local current_progress = PenanceStatusCache.get_progress(penance_id)
    local is_complete = penance.type == "custom_achievement_type" and current_progress >= penance -- For now track only custom ones.
    if(is_complete and not was_complete)then
        complete_penance(penance_id)
    elseif(not is_complete and was_complete) then
        reset_complete_penance(penance_id)
    else
        update_achievement_manager_definition(penance)
    end
end

local search_penance_id_by_name = function(...)
    local name = table.concat({...}, " ")
    if name == "" then
        mod:error("No penance name provided.")
        return nil
    end
    for _, penance in pairs(CustomPenanceDefinitions) do
        if(mod:localize(penance.title) == name) then
            return penance.id
        end
    end
end

local store_custom_penance_definition = function(penance)
    if CustomPenanceDefinitions[penance.id] then
        mod:error("Could not store custom penance with id "..penance.id..", id already exists")
        return
    end
    CustomPenanceDefinitions[penance.id] = penance
end

local add_penance_to_game_definitions = function(penance)
    penance.index = 0
    print("Adding custom penance to the game: "..penance.id)
    achievement_definitions_instance[penance.id] = penance
end

local unlock_pending_penances = function()
    for index, penance_id in pairs(pending_penances_ids) do
        notify_completion(penance_id)
    end
end

local update_penance = function(penance_id, penance)
    PenanceStatusCache.save_status(penance_id, penance.complete, penance.value, penance.target)
    update_achievement_manager_definition(penance)
end

local set_progress = function(penance_id, progress)
    local penance = CustomPenanceDefinitions[penance_id]
    PenanceStatusCache.set_progress(penance_id, progress)
    if(penance and progress >= penance.target)then
        complete_penance(penance_id)
    end
    update_achievement_manager_definition(penance)
end

local increase_progress = function(penance_id, progress)
    local penance = CustomPenanceDefinitions[penance_id]
    local previous = PenanceStatusCache.get_progress(penance_id)
    local updated_progress = previous + progress
    PenanceStatusCache.set_progress(penance_id, updated_progress)
    if(penance and updated_progress >= penance.target)then
        complete_penance(penance_id)
    end
    update_achievement_manager_definition(penance)
end

-- COMMANDS
local command_triggers = {
    custom_penances_commands = function (input) --[[no function here, this command's purpose is to return its output]] end,
    reset_custom_penance = function (input) reset_complete_penance(input) end,
    reset_all_penances = function (input) for _, penance in pairs(CustomPenanceDefinitions) do reset_complete_penance(penance.id) end end,
    complete_penance = function (input) complete_penance(input) end,
    complete_all_penances = function (input) for _, penance in pairs(CustomPenanceDefinitions) do complete_penance(penance.id) end  end,
    offset_penance_goal = function (penance_id, offset) offset_penance(penance_id, offset) end,
    get_penance_id = function (...) search_penance_id_by_name(...) end,
}

for _, command_definition in pairs(CommandDefinitions) do
    CommandTemplate.create(command_definition, command_triggers[command_definition.command])
end

-- LOCALIZATION
mod:add_global_localize_strings(CustomPenanceLocalization)

-- HOOKS AND STATE BASED ACTIONS

-- Make sure that other modules can tell that custom penances are done
-- WARNING: When a penance is selected in the penance view, THIS GETS CALLED EVERY SINGLE FRAME
local last_checked_custom_achievement = ""
local last_completed = false -- save this here to avoid doing two table lookups when the above happens
mod:hook(CLASS.AchievementsManager, "achievement_completed", function(original_function, self, player_id, achievement_id)
    if(last_checked_custom_achievement == achievement_id) then
        return last_completed, 0
    end
    if(CustomPenanceDefinitions[achievement_id] ~= nil) then
        last_checked_custom_achievement = achievement_id
        local penance_status = PenanceStatusCache.get_status(achievement_id)
        if(penance_status ~= nil) then
            last_completed = penance_status.completed
            return last_completed, 0
        end
        last_completed = false
        return last_completed
    end
    return original_function(self, player_id, achievement_id)
end)

-- Add the penances to the achievement definitions on init.
mod:hook_require("scripts/managers/achievements/achievement_definitions", function(instance)
    achievement_definitions_instance = instance
    for index, penance in pairs(CustomPenanceDefinitions) do
        local starts_complete = penance.initial_completion or false
        local start_progress = penance.initial_progress or 0      
        PenanceStatusCache.initialize_if_not_saved(penance.id, starts_complete, false, start_progress, penance.target)

        -- penance.index = index
        add_penance_to_game_definitions(penance)

        local status = PenanceStatusCache.get_status(penance.id)
        local is_complete = penance.type == "custom_achievement_type" and status.progress >= status.target
        if(starts_complete or is_complete) then
            complete_penance(penance.id)
        end
    end
end)

-- Create our own custom category, taking the place of "account" penances
mod:hook_require("scripts/settings/achievements/achievement_categories", function(instance)
    achievement_categories_instance = instance
    if(instance["account"]) then
        instance["account"] = nil
    end
    instance["custom"] = {
		name = "custom",
		display_name = "loc_custom_penance_category",
		parent_name = nil,
		sort_index = 0 -- we are replacing account category, at least for now
	}

    instance["custom_group_1"] = {
        name = "custom_group_1",
        display_name = "loc_custom_penance_group_1",
        parent_name = "custom",
        sort_index = 0
    }
end)

-- Create our own achievement type
mod:hook_require("scripts/managers/achievements/achievement_types", function(instance)
    instance["custom_achievement_type"] = CustomAchievementType
end)

-- Try to unlock pending penances whenever we finish loading, in case something was completed in the meantime
if(mod:is_enabled()) then
    mod.on_game_state_changed = function(status, state)
        if(status == "enter" and state == "GameplayStateRun" and not we_are_in_game)then
            we_are_in_game = true
            unlock_pending_penances()
        else
            we_are_in_game = false
        end
    end
end

-- And now we can add arbitrary callbacks wherever to trigger penances
mod.on_setting_changed = function(setting)
    print("setting changed "..setting)
    if(setting == "has_any_command_been_called") then
        print("should get complein'")
        if(mod:get("has_any_command_been_called") == true) then
            complete_penance("custom_penance_command_trigger")
        end
    end
end

-- EXPORTS
mod.add_penance = function(penance)
    if(penance.category == nil or not type(penance.category) == "string" or achievement_categories_instance[penance.category] == nil) then
        penance.category = "loc_custom_penance_category"
    end
    penance.type = "custom_achievement_type"
    PenanceStatusCache.initialize_if_not_saved(penance.id, penance.initial_completion or false, false, penance.initial_progress or 0, penance.target)
    add_penance_to_game_definitions(penance)
    store_custom_penance_definition(penance)
end
mod.complete_penance = complete_penance
mod.update_penance = update_penance
mod.increase_progress = increase_progress
mod.set_progress = set_progress
mod.create_penance_group = create_penance_group
