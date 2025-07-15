local CratesData = require(script.Parent.CratesData)

local CrateUtils = {}

-- Store server functions (will be set by server)
CrateUtils._serverFunctions = {}

-- Existing functions...
function CrateUtils.getCrateByName(name)
    for _, crate in ipairs(CratesData) do
        if crate.name == name then
            return crate
        end
    end
    return nil
end

-- Add the new crate inventory functions
function CrateUtils:getPlayerCrateInventory(player)
    if CrateUtils._serverFunctions.getPlayerCrateInventory then
        return CrateUtils._serverFunctions.getPlayerCrateInventory(player)
    end
    warn("CrateUtils inventory functions not initialized on server")
    return {}
end

function CrateUtils:removeItemFromInventory(player, itemId)
    if CrateUtils._serverFunctions.removeItemFromInventory then
        return CrateUtils._serverFunctions.removeItemFromInventory(player, itemId)
    end
    warn("CrateUtils inventory functions not initialized on server")
    return false
end

return CrateUtils
