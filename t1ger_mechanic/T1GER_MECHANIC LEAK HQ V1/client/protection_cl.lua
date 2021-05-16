
RegisterNetEvent('t1ger_mechanicjob:liftStateCL')
AddEventHandler('t1ger_mechanicjob:liftStateCL', function(k, id, val, vehicle, state)
    Config.MechanicShops[k].lifts[id] = val
    Config.MechanicShops[k].lifts[id].currentVeh = vehicle
    Config.MechanicShops[k].lifts[id].inUse = state
end)

RegisterNetEvent('t1ger_mechanicjob:syncVehicleBodyCL')
AddEventHandler('t1ger_mechanicjob:syncVehicleBodyCL', function(plate)
    RefreshVehicleDamage(vehicleData[plate].entity, plate)
end)

function GetBodyRepairProgression(vehicleEntity)
    if DoesEntityExist(vehicleEntity) then
        local numWheels = GetVehicleNumberOfWheels(vehicleEntity)
        local numDoors = (GetNumberOfVehicleDoors(vehicleEntity) - 2)
        local plate = GetVehicleNumberPlateText(vehicleEntity):gsub("^%s*(.-)%s*$", "%1")
        local numHood, numTrunk = 0, 0
        local totalValue = numDoors + numWheels + numHood + numTrunk + 2
        numWheels, numDoors = 0, 0
        for i = 0, (GetNumberOfVehicleDoors(vehicleEntity) - 2) - 1 do
            if vehicleData[plate].report.doors[i + 1] == false then
                numDoors = numDoors + 1
            end
        end
        if vehicleData[plate].report.doors[5] == false then
            numHood = numHood + 1
        end
        if vehicleData[plate].report.doors[6] == false then
            numTrunk = numTrunk + 1
        end
        for i = 0, GetVehicleNumberOfWheels(vehicleEntity) - 1 do
            if vehicleData[plate].report.wheels[i + 1] == false then
                numWheels = numWheels + 1
            end
        end
        local newValue = numWheels + numDoors + numHood + numTrunk
        return (math.floor((newValue / totalValue) * 100))
    end
end

function SpawnJackProp(vehicle)
    local heading = GetEntityHeading(vehicle)
    local objPos = GetEntityCoords(vehicle)
    carJackObj = CreateObject(GetHashKey("prop_carjack"), objPos.x, objPos.y, objPos.z - 0.95, true, true, true)
    SetEntityHeading(carJackObj, heading)
    FreezeEntityPosition(carJackObj, true)
end

function GetControlOfEntity(entity)
    local netTime = 15
    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and netTime > 0 do
        NetworkRequestControlOfEntity(entity)
        Citizen.Wait(100)
        netTime = netTime - 1
    end
end

RegisterNetEvent('t1ger_mechanicjob:JobDataCL')
AddEventHandler('t1ger_mechanicjob:JobDataCL', function(data)
    Config.NPC_RepairJobs = data
end)
