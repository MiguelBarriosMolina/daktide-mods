
local CommandDefinitions = {
    --[[    Format:
        name = The actual command to be typed in chat
        description = the description that appears in the dmf command info box
        help = The output message if we use /$name --help
        output = The message to be sent to chat when we trigger the command, after execution
        handler = not set here, the actual function that will get triggered on command use
    ]]
    {command = "custom_penances_commands",
    description = "Displays a list of all the available custom penance commands",
    output = "Custom penance commands. All commands can be run with --help to get more information about how they work.\ncomplete_penance - Complete a given custom penance\ncomplete_all_penances - Complete all the custom penances\nreset_custom_penance - Reset a specific custom penance\nreset_all_penances - Reset all the custom penances\noffset_penance_goal - Offset the stat and goal of a custom penance by the specified amount\nget_penance_id - Tries to find the penance id for a given custom penance name."},
    {command = "reset_custom_penance",
    description = "Mark the specified custom penance as not complete. Use /reset_custom_penance --help for more details.",
    help = "Marks a custom penance as not completed.\nIf the penance is tracking custom stats, they will be set to 0. \nIf the penance is tracking server stats managed by fatshark, those will remain unchanged. This can make the penance complete again immediately or as soon as the stat changes.\nIf you want to reset a penance with tracked server stats, use the command offset_penance_goal first.\nRequires a penance id as an argument. Eg: /reset_custom_penance custom_penance_overkill"},
    {command = "reset_all_penances",
    description = "Marks all custom penances as not complete. Use / --help for more details",
    help = "Marks all custom penances as not completed.\nIf a penance is tracking custom stats, they will be set to 0. \nIf a penance is tracking server stats managed by fatshark, those will remain unchanged. This can make the penance complete again immediately or as soon as the stat changes.\nIf you want to reset a penance with tracked server stats, use the command offset_penance_goal first."},
    {command = "complete_penance",
    description = "Mark the specified custom penance as completed. Use /complete_penance --help for more details",
    help = "Marks a custom penance as completed.\nIf a penance is tracking custom stats, they will be set to the goal. \nIf a penance is tracking server stats managed by fatshark, those will remain unchanged. This can make the penance reset to not completed eventually.\nIf you want to modify the progress of a penance with tracked server stats, use the command offset_penance_goal first.\nRequires a penance id as an argument. E.g.: /complete_penance custom_penance_overkill"},
    {command = "complete_all_penances",
    description = "Marks all custom penances as completed. Use /complete_all_penances --help for more details",
    help = "Marks all custom penances as completed.\nIf a penance is tracking custom stats, they will be set to the goal. \nIf a penance is tracking server stats managed by fatshark, those will remain unchanged. This can make the penance reset to not completed eventually.\nIf you want to modify the progress of a penance with tracked server stats, use the command offset_penance_goal first."},
    {command = "offset_penance_goal",
    description = "Offset the goal of the given penance by the specified amount, to restart or complete penaneces that track server stats. Use /offset_penance_goal --help for more details.",
    help = "Offset the goal of a penance\nUse this to modify the status of penances that track unmodifiable server stats, like total career kills\nDoing this, you can complete or reset these kinds of penances.\nIf no argument is passed, it will add the current stats to the goal, so you have to start the penance from the beginning.\nIf an argument is given, it will use that number instead. That number can be negative, to bring the goal closer to the current stat.\nExample: /offset_penance_goal custom_penance_overkill -10000 makes the goal of the overkill custom penance be 10000 kills less."},
    {command = "get_penance_id",
    description = "Try to find the penance id for the custom penance with a given name.USe /get_penance_id --help for more details.",
    help = "Tries to locate the penance id for a given penance name.\nThis is not guaranteed to work. If it does not, you can try searching the files of the mod that added the penance for the id.\nExample: /get_penance_id Straight up overkill"},
}

return CommandDefinitions