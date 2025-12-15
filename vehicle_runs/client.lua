-- client.lua (baseline working version)
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('vehraid:clientCreateVehicle')
AddEventHandler('vehraid:clientCreateVehicle', function(modelName, spawn, dest)
    Citizen.CreateThread(function()
        local model = GetHashKey(modelName)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        local veh = CreateVehicle(model, spawn.x, spawn.y, spawn.z, 0.0, true, false)
        local netId = VehToNet(veh)
        TriggerServerEvent('vehraid:serverRegisterVehicle', netId)

        -- simple AI driver
        local driver = GetPedInVehicleSeat(veh, -1)
        if driver == 0 then
            local pedModel = GetHashKey("s_m_y_cop_01")
            RequestModel(pedModel)
            while not HasModelLoaded(pedModel) do Wait(10) end
            driver = CreatePedInsideVehicle(veh, 4, pedModel, -1, true, false)
            SetBlockingOfNonTemporaryEvents(driver, true)
            SetPedKeepTask(driver, true)
        end
        TaskVehicleDriveToCoordLongrange(driver, veh, dest.x, dest.y, dest.z,
            18.0, 786603, 5.0)

        -- monitor vehicle
        Citizen.CreateThread(function()
            while DoesEntityExist(veh) do
                Wait(1000)
                if GetVehicleEngineHealth(veh) <= 0.0 or IsEntityDead(veh) then
                    local killerServerId = GetPlayerServerId(PlayerId())
                    TriggerServerEvent('vehraid:serverVehicleDestroyed', netId, killerServerId)
                    break
                end
                local dist = #(GetEntityCoords(veh) - vector3(dest.x, dest.y, dest.z))
                if dist < 10.0 then
                    TriggerServerEvent('vehraid:serverReachedDestination', netId)
                    break
                end
            end
        end)
    end)
end)

RegisterNetEvent('vehraid:clientDespawnVehicle')
AddEventHandler('vehraid:clientDespawnVehicle', function(netId, destroyed)
    local veh = NetToVeh(netId)
    if DoesEntityExist(veh) then DeleteEntity(veh) end
    print("[vehicle_runs] despawned", netId, "destroyed:", tostring(destroyed))
end)
