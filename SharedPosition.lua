Shared = require "ranalib_shared"
Constants = require "Constants"


function GetInformation(ID)
    local result = {}
    result = Shared.getTable(Constants.positionTable)

    return result[ID]
end

function StoreInformation(ID, Information)
    local result = {}
    result = Shared.getTable(Constants.positionTable)
    table.insert(result, ID, Information)
    Shared.storeTable(Constants.positionTable, result)
end

function GetTable()
    return Shared.getTable(Constants.positionTable)
end