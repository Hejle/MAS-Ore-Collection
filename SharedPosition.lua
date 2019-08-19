local sharedPosition = {}
Shared = require "ranalib_shared"
Constants = require "Constants"

function sharedPosition.GetInformation(ID)
    local result = {}
    result = Shared.getTable(Constants.positionTable)

    return result[ID]
end

function sharedPosition.StoreInformation(ID, Information)
    local result = {}
    result = Shared.getTable(Constants.positionTable)
    if result == nil then
        result = {}
    end
    table.insert(result, ID, Information)
    Shared.storeTable(Constants.positionTable, result)
end

function sharedPosition.GetTable()
    return Shared.getTable(Constants.positionTable)
end

return sharedPosition