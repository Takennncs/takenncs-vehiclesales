local QBCore = exports['qb-core']:GetCoreObject()
local sellingVehicles = {}

QBCore.Commands.Add('sellvehicle', 'Müü sõiduk', {
    {name = 'id', help = 'Isiku ID'},
    {name = 'price', help = 'Hind'}
}, true, function(source, args)
    local seller = source
    local targetId = tonumber(args[1])
    local price = tonumber(args[2])
    
    if not targetId or not price or price <= 0 then
        TriggerClientEvent('QBCore:Notify', seller, 'Vigane ID või hind', 'error')
        return
    end
    
    if seller == targetId then
        TriggerClientEvent('QBCore:Notify', seller, 'Sa ei saa iseendale müüa', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', seller, 'Isikut ei ole linnas', 'error')
        return
    end
    
    TriggerClientEvent('takenncs-vehiclesales:getVehicleData', seller, targetId, price)
end)

RegisterServerEvent('takenncs-vehiclesales:sendVehicleData')
AddEventHandler('takenncs-vehiclesales:sendVehicleData', function(targetId, price, plate, model)
    local seller = source
    
    if not plate or not model then
        TriggerClientEvent('QBCore:Notify', seller, 'Sa pead olema autos', 'error')
        return
    end
    
    sellingVehicles["veh_"..seller] = {
        plate = plate,
        model = model,
        price = price
    }
    
    TriggerClientEvent('takenncs-vehiclesales:checkBuyerDistance', seller, targetId, price, plate, model)
end)

RegisterServerEvent('takenncs-vehiclesales:buyerDistanceChecked')
AddEventHandler('takenncs-vehiclesales:buyerDistanceChecked', function(targetId, price, plate, model, isNearby)
    local seller = source
    
    if not isNearby then
        TriggerClientEvent('QBCore:Notify', seller, 'Ostja pole sinu lähedal', 'error')
        return
    end
    
    local xPlayer = QBCore.Functions.GetPlayer(seller)
    if not xPlayer then
        return
    end
    
    local sellerName = xPlayer.PlayerData.charinfo.firstname..' '..xPlayer.PlayerData.charinfo.lastname
    
    TriggerClientEvent('takenncs-vehiclesales:showPurchaseOffer', targetId, {
        sellerId = seller,
        sellerName = sellerName,
        price = price,
        plate = plate,
        model = model
    })
end)

RegisterServerEvent('takenncs-vehiclesales:acceptOffer')
AddEventHandler('takenncs-vehiclesales:acceptOffer', function(offerData)
    local buyer = source
    local seller = offerData.sellerId
    local price = offerData.price
    local plate = offerData.plate
    local model = offerData.model
    
    local sellerPed = GetPlayerPed(seller)
    local buyerPed = GetPlayerPed(buyer)
    
    if not sellerPed or not buyerPed then
        TriggerClientEvent('QBCore:Notify', buyer, 'Viga kauguse kontrollimisel', 'error')
        return
    end
    
    local sellerCoords = GetEntityCoords(sellerPed)
    local buyerCoords = GetEntityCoords(buyerPed)
    local distance = #(sellerCoords - buyerCoords)
    
    if distance > 3.0 then
        TriggerClientEvent('QBCore:Notify', buyer, 'Müüja pole enam lähedal', 'error')
        TriggerClientEvent('QBCore:Notify', seller, 'Ostja pole enam lähedal', 'error')
        return
    end
    
    if not sellingVehicles["veh_"..seller] then
        TriggerClientEvent('QBCore:Notify', buyer, 'Müük on aegunud', 'error')
        return
    end
    
    if sellingVehicles["veh_"..seller].plate ~= plate then
        TriggerClientEvent('QBCore:Notify', buyer, 'Vale numbrimärk', 'error')
        return
    end
    
    local xPlayer = QBCore.Functions.GetPlayer(seller)
    local tPlayer = QBCore.Functions.GetPlayer(buyer)
    
    if not xPlayer or not tPlayer then
        TriggerClientEvent('QBCore:Notify', buyer, 'Viga mängijate andmete laadimisel', 'error')
        return
    end
    
    MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = @citizenid AND plate = @plate', {
        ['@citizenid'] = xPlayer.PlayerData.citizenid,
        ['@plate'] = plate
    }, function(result)
        if not result or #result == 0 then
            TriggerClientEvent('QBCore:Notify', seller, 'See auto ei kuulu sulle', 'error')
            TriggerClientEvent('QBCore:Notify', buyer, 'Müüja ei oma seda autot', 'error')
            return
        end
        
        local buyerBank = tPlayer.PlayerData.money.bank
        
        if buyerBank < price then
            TriggerClientEvent('QBCore:Notify', seller, 'Ostjal pole piisavalt raha', 'error')
            TriggerClientEvent('QBCore:Notify', buyer, 'Sul pole piisavalt raha', 'error')
            return
        end
        
        tPlayer.Functions.RemoveMoney('bank', price)
        xPlayer.Functions.AddMoney('bank', price)
        
        MySQL.update('UPDATE player_vehicles SET citizenid = @newOwner WHERE plate = @plate', {
            ['@newOwner'] = tPlayer.PlayerData.citizenid,
            ['@plate'] = plate
        }, function(affectedRows)
            if affectedRows and affectedRows > 0 then
                sellingVehicles["veh_"..seller] = nil
                
                TriggerClientEvent('QBCore:Notify', seller, 'Müüsid edukalt '..model..' hinnaga $'..price, 'success')
                TriggerClientEvent('QBCore:Notify', buyer, 'Ostsid edukalt '..model..' hinnaga $'..price, 'success')
                
                if exports['takenncs-vehiclekeys'] then
                    local vehicle = GetVehiclePedIsIn(GetPlayerPed(seller), false)
                    if vehicle and vehicle > 0 then
                        exports['takenncs-vehiclekeys']:AddKey(vehicle, buyer)
                        exports['takenncs-vehiclekeys']:ChangeOwner(vehicle, buyer)
                    end
                end
            else
                TriggerClientEvent('QBCore:Notify', seller, 'Viga omaniku vahetamisel', 'error')
                TriggerClientEvent('QBCore:Notify', buyer, 'Viga omaniku vahetamisel', 'error')
                
                xPlayer.Functions.RemoveMoney('bank', price)
                tPlayer.Functions.AddMoney('bank', price)
            end
        end)
    end)
end)

RegisterServerEvent('takenncs-vehiclesales:buyerDeclined')
AddEventHandler('takenncs-vehiclesales:buyerDeclined', function(sellerId)
    TriggerClientEvent('QBCore:Notify', sellerId, 'Ostja keeldus ostust', 'error')
end)

QBCore.Functions.CreateCallback('takenncs-vehiclesales:GetTargetName', function(source, cb, targetId)
    local target = QBCore.Functions.GetPlayer(targetId)
    if target then
        cb(target.PlayerData.charinfo.firstname..' '..target.PlayerData.charinfo.lastname)
    else
        cb(nil)
    end
end)

QBCore.Functions.CreateCallback('takenncs-vehiclesales:checkIfOwnsVehicle', function(source, cb, plate)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = @identifier AND plate = @plate', {
        ['@identifier'] = xPlayer.PlayerData.citizenid,
        ['@plate'] = plate
    }, function(result)
        cb(result and result[1] ~= nil)
    end)
end)

RegisterServerEvent('takenncs-vehiclesales:testVehicleData')
AddEventHandler('takenncs-vehiclesales:testVehicleData', function(price, plate, model)
    local playerId = source
    local xPlayer = QBCore.Functions.GetPlayer(playerId)
    
    if not xPlayer then
        return
    end
    
    if xPlayer.PlayerData.money.bank < price then
        TriggerClientEvent('QBCore:Notify', playerId, 'Pole piisavalt raha!', 'error')
        return
    end
    
    xPlayer.Functions.RemoveMoney('bank', price)
    
    MySQL.query('SELECT * FROM player_vehicles WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result and #result > 0 then
            TriggerClientEvent('QBCore:Notify', playerId, 'See auto on juba kellegi oma!', 'error')
            xPlayer.Functions.AddMoney('bank', price)
        else
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @state)', {
                ['@license'] = xPlayer.PlayerData.license,
                ['@citizenid'] = xPlayer.PlayerData.citizenid,
                ['@vehicle'] = model,
                ['@hash'] = GetHashKey(model),
                ['@mods'] = json.encode({}),
                ['@plate'] = plate,
                ['@garage'] = 'A',
                ['@state'] = 0
            }, function(inserted)
                if inserted then
                    TriggerClientEvent('QBCore:Notify', playerId, 'Ostsid auto '..model..' hinnaga $'..price, 'success')
                else
                    TriggerClientEvent('QBCore:Notify', playerId, 'Auto lisamine ebaõnnestus', 'error')
                    xPlayer.Functions.AddMoney('bank', price)
                end
            end)
        end
    end)
end)