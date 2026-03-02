local QBCore = exports['qb-core']:GetCoreObject()
local prop = nil
local contractData = nil

RegisterNetEvent('takenncs-vehiclesales:getVehicleData')
AddEventHandler('takenncs-vehiclesales:getVehicleData', function(targetId, price)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        TriggerServerEvent('takenncs-vehiclesales:sendVehicleData', targetId, price, nil, nil)
        QBCore.Functions.Notify('Pead olema autos', 'error')
        return
    end
    
    local plate = QBCore.Functions.GetPlate(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    
    TriggerServerEvent('takenncs-vehiclesales:sendVehicleData', targetId, price, plate, model)
end)

RegisterNetEvent('takenncs-vehiclesales:checkBuyerDistance')
AddEventHandler('takenncs-vehiclesales:checkBuyerDistance', function(targetId, price, plate, model)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))
    
    if not targetPed or targetPed == 0 then
        TriggerServerEvent('takenncs-vehiclesales:buyerDistanceChecked', targetId, price, plate, model, false)
        return
    end
    
    local targetCoords = GetEntityCoords(targetPed)
    local myCoords = GetEntityCoords(PlayerPedId())
    local distance = #(myCoords - targetCoords)
    
    TriggerServerEvent('takenncs-vehiclesales:buyerDistanceChecked', targetId, price, plate, model, distance <= 3.0)
end)

RegisterNetEvent('takenncs-vehiclesales:showPurchaseOffer')
AddEventHandler('takenncs-vehiclesales:showPurchaseOffer', function(offerData)
    contractData = offerData
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showPurchaseOffer',
        sellerName = offerData.sellerName,
        sellerId = offerData.sellerId,
        price = offerData.price,
        plate = offerData.plate,
        model = offerData.model
    })
end)

RegisterNUICallback("offerAction", function(data, cb)
    if data.action == "accept" then
        QBCore.Functions.Notify('Nõustusid ostuga', 'success')
        SetNuiFocus(false, false)
        TriggerServerEvent('takenncs-vehiclesales:acceptOffer', data.data)
        
    elseif data.action == "decline" then
        QBCore.Functions.Notify('Keeldusid ostust', 'error')
        SetNuiFocus(false, false)
        
        if contractData then
            TriggerServerEvent('takenncs-vehiclesales:buyerDeclined', data.sellerId)
            contractData = nil
        end
        
    elseif data.action == "close" then
        SetNuiFocus(false, false)
        
        if contractData then
            TriggerServerEvent('takenncs-vehiclesales:buyerDeclined', contractData.sellerId)
            contractData = nil
        end
    end
    cb('ok')
end)

RegisterNetEvent('takenncs-vehiclesales:testGetVehicle')
AddEventHandler('takenncs-vehiclesales:testGetVehicle', function(price)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        TriggerServerEvent('takenncs-vehiclesales:testVehicleData', price, nil, nil)
        QBCore.Functions.Notify('Pead olema autos', 'error')
        return
    end
    
    local plate = QBCore.Functions.GetPlate(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    
    QBCore.Functions.Notify('Töötlen ostu...', 'info')
    TriggerServerEvent('takenncs-vehiclesales:testVehicleData', price, plate, model)
end)