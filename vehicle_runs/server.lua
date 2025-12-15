-- server.lua (baseline working version)
local QBCore = exports['qb-core']:GetCoreObject()

local REWARD_ITEM = "goldbar"
local REWARD_AMOUNT = 1
local spawned = {}

local function dprint(...) print("[vehicle_runs]", ...) end

-- Command to spawn a run manually
RegisterCommand("spawnrun", function(src)
    local players = GetPlayers()
    if #players == 0 then dprint("no players online") return end
    local creator = tonumber(players[1])
    local spawn = {x=215.0,y=-810.0,z=29.7}
    local dest = {x=-1000.0,y=-200.0,z=37.0}
    TriggerClientEvent('vehraid:clientCreateVehicle', creator, "rumpo", spawn, dest)
end, false)

-- Client reports back the netId
RegisterNetEvent('vehraid:serverRegisterVehicle')
AddEventHandler('vehraid:serverRegisterVehicle', function(netId)
    spawned[tostring(netId)] = true
    dprint("registered netId", netId)
end)

-- Client reports destruction
RegisterNetEvent('vehraid:serverVehicleDestroyed')
AddEventHandler('vehraid:serverVehicleDestroyed', function(netId, killerServerId)
    local key = tostring(netId)
    dprint("destruction reported for", key, "by", killerServerId)
    if not spawned[key] then dprint("unknown netId", key) return end
    spawned[key] = nil

    local killer = QBCore.Functions.GetPlayer(killerServerId)
    if killer then
        killer.Functions.AddItem(REWARD_ITEM, REWARD_AMOUNT)
        TriggerClientEvent('QBCore:Notify', killerServerId,
            ("You received %d %s!"):format(REWARD_AMOUNT, REWARD_ITEM), "success")
        dprint("reward given to", killerServerId)
    else
        dprint("killer not found")
    end
end)

-- Client reports arrival at destination
RegisterNetEvent('vehraid:serverReachedDestination')
AddEventHandler('vehraid:serverReachedDestination', function(netId)
    local key = tostring(netId)
    if spawned[key] then
        spawned[key] = nil
        dprint("vehicle reached destination", key)
        TriggerClientEvent('vehraid:clientDespawnVehicle', -1, netId, false)
    end
end)
