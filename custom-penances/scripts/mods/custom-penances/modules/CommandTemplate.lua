local mod = get_mod("custom-penances")
local CommandTemplate = {}

CommandTemplate.create = function (command_definition, handler)
    local baseHandler = function(input)
        print("command called")
        mod:set("has_any_command_been_called", true)
        if(type(input) == "string" and string.sub(input, -6) == "--help" and command_definition.help)then
            mod:echo(command_definition.help)
        else
            handler(input)
        end
        if(command_definition.output) then
            mod:echo(command_definition.output)
        end
    end
    mod:command(command_definition.command, command_definition.description, baseHandler)
end

return CommandTemplate