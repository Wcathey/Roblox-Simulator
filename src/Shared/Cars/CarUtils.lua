local CarsData = require(script.Parent.CarsData)

local CarUtils = {}

-- Helper to find a car by Id from all car categories
local function findCarById(carId)
    local lists = {
        CarsData.StarterCars,
        CarsData.BountyCars,
        CarsData.RebirthCars,
        CarsData.GamePassCars,
    }

    for _, list in ipairs(lists) do
        for _, car in ipairs(list) do
            if car.Id == carId then
                return car
            end
        end
    end

    return nil
end

function CarUtils:PlayerMeetsRequirements(playerData, carId)
    local car = findCarById(carId)
    if not car then
        -- If car not found, assume no requirements or invalid car
        return true
    end

    local req = car.Requirements or {}

    if playerData.Level < (req.Level or 0) then return false end
    if playerData.Rebirth < (req.Rebirth or 0) then return false end

    if req.Achievements then
        for _, requiredAch in ipairs(req.Achievements) do
            local hasAch = false
            for _, playerAch in ipairs(playerData.Achievements or {}) do
                if playerAch == requiredAch then
                    hasAch = true
                    break
                end
            end
            if not hasAch then return false end
        end
    end

    return true
end

return CarUtils
