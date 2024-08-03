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





RegisterNetEvent('PS_Lottery:AdminMenue', function(participantCount, potValue, lastWinner)
    
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



RegisterNetEvent('PS_Lottery:CheckWinClient', function()
    local clientId = GetPlayerServerId(PlayerId()) 
    TriggerServerEvent('PS_Lottery:CheckWin', clientId) 
end)



RegisterNetEvent('PS_Lottery:CheckStatsClient', function()
    local clientId = GetPlayerServerId(PlayerId()) 
    TriggerServerEvent('PS_Lottery:CheckStats', clientId) 
end)


RegisterNetEvent('PS_Lottery:OpenLotteryTicketProgress', function(pos, identifier)
    local progressName = "PS_lottery_openticket"
    local progressDuration = Config.OpenLotteryTicketDuration
    local progressLabel = Config.OpenLotteryTicketLabel
    local progressanimDict = "mp_arresting"
    local progressanim = "a_uncuff"
    local clientId = GetPlayerServerId(PlayerId()) 

    if Config.Progressbar == "qb-progressbar" then
        exports['progressbar']:Progress({
            name = progressName,
            duration = progressDuration,
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = true,
                disableCombat = true,
            },
            animation = {
                animDict = progressanimDict,
                anim = progressanim,
                flags = 49,
            },
            prop = { },
            propTwo = {}
        }, function(cancelled)
            if not cancelled then
               TriggerServerEvent('PS_Lottery:lotteryParticipation', clientId)
            else
                
            end
        end)
    elseif Config.Progressbar == "ESX-Progressbar" then 
        exports["esx_progressbar"]:Progressbar(progressLabel, progressDuration, {
            FreezePlayer = true, 
            animation = {
                type = "anim",
                dict = progressanimDict, 
                lib = progressanim
            },
            onFinish = function()
                TriggerServerEvent('PS_Lottery:lotteryParticipation', clientId)
            end
        })
    elseif Config.Progressbar == "custom-progressbar" then 
        CustomProgressbar(progressName, progressDuration, progressLabel, progressanimDict, progressanim)
        Wait(progressDuration)
        TriggerServerEvent('PS_Lottery:lotteryParticipation', clientId)
    elseif Config.Progressbar == "ox-progressbar" then 
        if lib.progressBar({
            duration = progressDuration,
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = progressanimDict,
                clip = progressanim
            },
        }) then
            TriggerServerEvent('PS_Lottery:lotteryParticipation', clientId)
        end
    elseif Config.Progressbar == "ox-progressCircle" then 
        if lib.progressCircle({
            duration = progressDuration,
            label = progressLabel,
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = progressanimDict,
                clip = progressanim
            },
        }) then
            TriggerServerEvent('PS_Lottery:lotteryParticipation', clientId)
        end
    end
end)