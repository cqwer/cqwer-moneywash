-- [CQWER] --
QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData')
AddEventHandler('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)


local washers = {
    {x=1135.70, y=-992.30, z=46.11, h=99.29, length=1.0, width=1.2},
    {x=1135.43, y=-990.81, z=46.11, h=99.29, length=1.0, width=1.2},
    {x=1135.30, y=-989.52, z=46.11, h=99.29, length=1.0, width=1.2},
    {x=1135.15, y=-988.17, z=46.11, h=99.29, length=1.0, width=1.2},
}


function isWashing(washer)
    local washing = promise.new()
    QBCore.Functions.TriggerCallback("cqwerMoneyWash:isWashing", function(result)
        washing:resolve(result)
    end, washer)
    Wait(100)
    return Citizen.Await(washing)
end

function isReady(washer)
    local ready = promise.new()
    QBCore.Functions.TriggerCallback("cqwerMoneyWash:isReady", function(result)
        ready:resolve(result)
    end, washer)
    Wait(100)
    return Citizen.Await(ready)
end

CreateThread(function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == 'realestate' then
        for washer, data in pairs(washers) do 
            exports['qb-target']:AddBoxZone("wash"..washer, vector3(data.x, data.y, data.z), data.length, data.width, {
                name="wash"..washer,
                heading=data.h,
                debugPoly=false,
                minZ=data.z - 1,
                maxZ=data.z + 1,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "cqwerMoneyWash:openwasher",
                            icon = "fa-solid fa-gauge-high",
                            label = "Çamaşırlığı Aç",
                            id = washer,
                            canInteract = function()
                                if not isWashing(washer) then return true else return false end 
                            end
                        },
                        {
                            type = "server",
                            event = "cqwerMoneyWash:startwasher",
                            icon = "fa-solid fa-hourglass-start",
                            label = "Yıkamayı Başlat",
                            id = washer,
                            canInteract = function()
                                if not isWashing(washer) then return true else return false end 
                            end
                        },
                        {
                            type = "server",
                            event = "cqwerMoneyWash:collect",
                            icon = "fa-solid fa-hand-holding-usd",
                            label = "Paraları Al",
                            id = washer,
                            canInteract = function()
                                return isReady(washer)
                            end
                        },
                    },
                    distance = 3.0
            })
        end
    end
end)


RegisterNetEvent("cqwerMoneyWash:openwasher", function(data)
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name == 'realestate' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "washer"..data.id, {maxweight = 1500000, slots = 10})
        TriggerEvent("inventory:client:SetCurrentStash", "washer"..data.id)
    end
end)





local tablo =  vector3(1132.36, -995.7, 46.11)
    Citizen.CreateThread(function()
        while true do
            local PlayerData = QBCore.Functions.GetPlayerData()
            local playerPed = PlayerPedId()
            local pedCoords = GetEntityCoords(playerPed)
            local distance = #(pedCoords - tablo)
            inUI = false
            local time = 1000
            if distance < 20 then
                time = 1
                if distance < 0.7 then
                    inUI = true
                    exports['seind-ui']:TextDisplay("Para Deposu", "paradepo", "fas fa-circle", "E")
                    if PlayerData.job.name == 'realestate' then
                        if IsControlJustReleased(0, 38) then
                            exports['seind-ui']:HideText("ikinciel")
                            TriggerEvent("inventory:client:SetCurrentStash", "paradepo_", QBCore.Key)
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", "paradepo_", {maxweight = 100000,slots = 50})
                        end
                    end 
                    if not inUI then
                        exports['seind-ui']:HideText("paradepo")
                    end
                else
                    exports['seind-ui']:HideText("paradepo")
                end
            end
            Citizen.Wait(time)
        end
    end)