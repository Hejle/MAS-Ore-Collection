local sharedPosition = {}
Shared = require "ranalib_shared"
Constants = require "Libs.Constants"

function sharedPosition.GetInformation(ID)
    local result = {}
    result = Shared.getTable(Constants.positionTable)

    return result[ID]
end

function HelloWorldFunction()
    say("World")
end

function sharedPosition.PublicFunction()
    say("Hello")
    return HelloWorldFunction
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

function sharedPosition.GetInformationFromList(IDs)
    local result = {}
    local returnTable = {}
    result = Shared.getTable(Constants.positionTable)

    for k,v in pairs(result) do
        for i=1,#IDs do
            if IDs[i] == k then
                table.insert(returnTable, k, v)
            end
        end
    end
    return returnTable
end

function sharedPosition.GetInformationSorted(sortingFunction)
    local result = {}
    local returnTable = {}
    result = Shared.getTable(Constants.positionTable)
    return sortingFunction(result)
end

return sharedPosition