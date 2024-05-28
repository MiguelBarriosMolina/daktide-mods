local mod = get_mod("custom-penances")


-- The game checks if a penance is completed A LOT
-- We are using an in-memory table to cache our latest saved penance status to avoid
-- Calling mod:get() a hundred times per penance.
-- When saving any change, a copy of that change is stored to status_cache
-- Getting those changes will always get the cached version
-- Data will always be updated in the cached table, since there's no other way for the setting to be changed

local PenanceStatusCache = {}

-- contains:
-- id = {completed, notified, progress, target}
-- "status_id" = { true, false, 10, 10}
local status_cache = {}

local settings_string_to_table = function(penance_id, status_string)
    print("Saving status '"..status_string.."' to cache for penance '"..penance_id.."'")
    local index = 1
    local status = {}
    for substring in string.gmatch(status_string, "([^:]+)") do
        if(index == 1) then
            status.completed = substring=="1"
        elseif(index == 2) then
            status.notified = substring=="1"
        elseif(index == 3) then
            status.progress = tonumber(substring)
        else
            status.target = tonumber(substring)
        end
        index = index+1
    end
    status_cache[penance_id] = status
end

local cache_to_settings_string = function(penance_id)
    local table = status_cache[penance_id]
    local completed = "0"
    if(table ~= nil and table.completed) then
        completed = "1"
    end
    local notified = "0"
    if(table ~= nil and table.notified) then
        notified = "1"
    end
    return completed..":"..notified..":"..tostring(table.progress or 0)..":"..tostring(table.target or 0)
end

local commit = function(penance_id)
    local result = cache_to_settings_string(penance_id)
    print("WARN: EXPENSIVE OPERATION - Commiting penance '"..penance_id.."' status '" ..result.."' to settings.")
    mod:set(penance_id.."_status", result)
end

local get_status = function(penance_id)
    if(status_cache[penance_id]) then
        return status_cache[penance_id]
    end
    print("Received request for penance status not found in cache with id '"..penance_id.."'. Retrieving it from settings.")
    local status_string = mod:get(penance_id.."_status")
    if(status_string == nil) then
        mod:set(penance_id.."_status", "0:0:0")
    end
    settings_string_to_table(penance_id, status_string)
    return status_cache[penance_id]
end

local save_status = function(penance_id, completed, notified, progress, target)
    status_cache[penance_id] = {completed = completed, notified = notified, progress = progress, target = target}
    commit(penance_id)
end

local initialize_if_not_saved = function(penance_id, completed, notified, progress, target)
    if(status_cache[penance_id] ~= nil) then
        print("Penance with id '"..penance_id.."'already exists in cache. Skipping initialization")
        return
    end
    print("Initializing penance '"..penance_id.."'")
    completed = completed or false
    notified = notified or false
    progress = progress or 0
    target = target or 1
    --TODO Uncomment this for release
    --[[
    local stored_status = mod:get(penance_id.."_status")
    if(stored_status ~= nil) then
        print("Status found in settings for penance "..penance_id)
        cache_string_to_table(penance_id, stored_status)
        return
    end
    --]]
    save_status(penance_id, completed, notified, progress, target)
end

local set_complete = function(penance_id, completed)
    local cached = status_cache[penance_id]
    if(cached ~= nil and cached.completed == completed) then
        return
    end
    cached.completed = completed
    if(not completed and cached.notified) then
        cached.notified = false
    end
    status_cache[penance_id] = cached -- Just in case lua uses copies and not references, i have no clue...
    commit(penance_id)
end

local set_notified = function(penance_id, notified)
    if(status_cache[penance_id] and status_cache[penance_id].notified == notified) then
        return
    end
    status_cache[penance_id].notified = notified
    commit(penance_id)
end

local set_progress = function(penance_id, progress)
    if(status_cache[penance_id] and status_cache[penance_id].progress == progress) then
        return
    end
    status_cache[penance_id].progress = progress
    commit(penance_id)
end

local set_target = function(penance_id, value)
    if(status_cache[penance_id] and status_cache[penance_id].value == value) then
        return
    end
    status_cache[penance_id].value = value
    commit(penance_id)
end

local is_complete = function(penance_id)
    local status = status_cache[penance_id]
    if(status == nil) then
        status = get_status(penance_id)
    end
    return status.completed
end

local was_notified = function(penance_id)
    local status = status_cache[penance_id]
    if(status == nil) then
        status= get_status(penance_id)
    end
    return status.notified
end

local get_progress = function(penance_id)
    local status = status_cache[penance_id]
    if(status == nil) then
       status = get_status(penance_id)
    end
    return status.progress
end

local get_target = function(penance_id)
    local status = status_cache[penance_id]
    if(status == nil) then
        status = get_status(penance_id)
    end
    return status.target
end

PenanceStatusCache.get_status = get_status
PenanceStatusCache.save_status = save_status
PenanceStatusCache.set_complete = set_complete
PenanceStatusCache.set_notified = set_notified
PenanceStatusCache.set_progress = set_progress
PenanceStatusCache.set_target = set_target
PenanceStatusCache.is_complete = is_complete
PenanceStatusCache.was_notified = was_notified
PenanceStatusCache.get_progress = get_progress
PenanceStatusCache.get_target = get_target
PenanceStatusCache.initialize_if_not_saved = initialize_if_not_saved

return PenanceStatusCache