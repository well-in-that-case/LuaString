local profiler = require("profiler")

function profiler.most_common(fn, ...)
    local common = {}
    for i = 1, 5000 do
        local key = tostring(profiler.once(fn, ...))
        common[key] = (common[key] or 0) + 1
    end

    local most_common_key = nil
    local most_common = 0
    for key, value in pairs(common) do
        if value > most_common then
            most_common = value
            most_common_key = key
        end
    end

    return most_common_key
end

return profiler