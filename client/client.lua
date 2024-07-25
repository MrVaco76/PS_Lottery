if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end

if Config.Framework == "ESX" then
    while not ESX do
        Citizen.Wait(100)
    end
end

if Config.Framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
end




RegisterNetEvent('PS_Lottery:AdminMenue')
AddEventHandler('PS_Lottery:AdminMenue', function(participantCount, potValue, lastWinner)
    
    local PotAmount 
    local lastwin = json.encode(lastWinner)
    
    if potValue == nil then 
        PotAmount = 0
    else 
        PotAmount = potValue
    end

    local winner
    if lastwin == "null" then 
        winner = translations.NoWinnerAdmin
    else 
        winner = lastwin
    end

    local input = lib.inputDialog(translations.LotteryAdminMenueTitel, {
        {type = 'input', label = translations.LotteryParticipated, default = participantCount, disabled = true},
        {type = 'input', label = translations.LotteryPot, default  = PotAmount},
        {type = 'checkbox', label = translations.manualDrawing},
        {type = 'textarea',label = translations.LastWinner, default = winner, disabled = true}
    })

    if input == nil then 
        return nil 
    else 
        local participantCountNew = input[1]
        local potValueNew = input[2]
        local ManualDraw = input[3]
        local lastWinnerNew = input[4]

        if ManualDraw == true then 
            local alertDraw = lib.alertDialog({
                header = translations.LotteryAdminMenueTitel,
                content = translations.LotteryDrawAdminCheck,
                centered = true,
                cancel = true
            })

            if alertDraw == "cancel" then
			
                return nil
				
            else
                TriggerServerEvent('PS_Lottery:lotteryDrawing')
                local msg = translations.LotteryPotDrawnAdmin
                local type = "success"
                Notify(msg, type)

            end

        end
        
        if potValueNew ~= potValue then
            local ConfirmChangePot = string.format(translations.ConfirmChangePot, potValueNew)
            local alert = lib.alertDialog({
                header = translations.LotteryAdminMenueTitel,
                content = ConfirmChangePot,
                centered = true,
                cancel = true
            })
			
            if alert == "cancel" then
			
                return nil
				
            else
                TriggerServerEvent('PS_Lottery:UpDateFromAdminMenue', potValueNew)
                local msg = string.format(translations.LotteryPotUpdated, potValueNew)
                local type = "success"
                
                Notify(msg, type)

            end

            return input[2]
        end
    end
end)


RegisterNetEvent('PS_Lottery:CheckWinClient')
AddEventHandler('PS_Lottery:CheckWinClient', function()
    local clientId = GetPlayerServerId(PlayerId()) 
    TriggerServerEvent('PS_Lottery:CheckWin', clientId) 
end)