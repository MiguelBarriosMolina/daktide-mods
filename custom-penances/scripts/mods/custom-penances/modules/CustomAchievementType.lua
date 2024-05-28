local mod = get_mod("custom-penances")
local PenanceStatusCache = mod:io_dofile("custom-penances/scripts/mods/custom-penances/modules/PenanceStatusCache")

local CustomAchievement = {
	trigger_type = "custom"
}

--[[ FIELDS:

In all of the methods, the only parameter we will ever use is achievement_definition.
Function setup(achievement_definition, scratch_pad, player_id): Initialize. Returns bool indicating if the achievement is already finished.
Field trigger_type: String. Values in source are "stat", "meta" or nil. Stats are anything that can be tracked with raw numbers, meta is usually a group of other penances, and
	nil is usually an achievement triggered at specific progression points, like completing the tutorial.
Function trigger (achievement_definition, scratch_pad, player_id, stat_name, stat_value) -> Returns if the penance has been completed. Similar to setup, but without the initialization.
Function get_triggers(achievement_definition) -> Returns the triggers listed in the achievement_definition. Usually either the tracked stat or the penances required to unlock a group penance.
Function verifier(achievement_definition) -> Checks if achievement definition contains all required fields. Returns either true or false, "Error message"
Function get_progress(achievement_definition, player) -> Checks 
]]

CustomAchievement.trigger = function (achievement_definition, scratch_pad, player_id, achievement_id)
	local complete = PenanceStatusCache.is_complete(achievement_definition.id)
	if complete ~= nil and type(complete) == "boolean" then
		return complete
	end
	return false
end

CustomAchievement.setup = function (achievement_definition, scratch_pad, player_id)
	local complete = PenanceStatusCache.is_complete(achievement_definition.id)
	if complete ~= nil and type(complete) == "boolean" then
		return complete
	end
	return false
end

CustomAchievement.verifier = function (achievement_definition)
	return true
end

CustomAchievement.get_triggers = function (achievement_definition)
	return nil
end

CustomAchievement.get_progress = function (achievement_definition, player)
	print("Retrieving progress for achievement "..achievement_definition.id)
	local progress = PenanceStatusCache.get_progress(achievement_definition.id) or 0
	local target = PenanceStatusCache.get_target(achievement_definition.id) or 1
	print("Returning"..tostring(progress), tostring(target))
	return progress, target
end

return CustomAchievement
