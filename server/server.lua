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

local isWinner = false

local function ExtractIdentifiers(playerId)
    local identifiers = {}

    for i = 0, GetNumPlayerIdentifiers(playerId) - 1 do
        local id = GetPlayerIdentifier(playerId, i)

        if string.find(id, "steam:") then
            identifiers['steam'] = id
        elseif string.find(id, "discord:") then
            identifiers['discord'] = id
        elseif string.find(id, "license:") then
            identifiers['license'] = id
        elseif string.find(id, "license2:") then
            identifiers['license2'] = id
        end
    end

    return identifiers
end

if Config.Framework == "qb-core" then 
    QBCore.Functions.CreateUseableItem(Config.LotteryItem, function(source, item)
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            TriggerEvent('PS_Lottery:lotteryParticipation', source)
            player.Functions.RemoveItem(Config.LotteryItem, 1)
        else
            print("Error: QBCore player not found")
        end
    end)
end

if Config.Framework == "ESX" then 
    ESX.RegisterUsableItem(Config.LotteryItem, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            TriggerEvent('PS_Lottery:lotteryParticipation', source)
            xPlayer.removeInventoryItem(Config.LotteryItem, 1)
        else
            print("Error: ESX player not found")
        end
    end)
end

if Config.UseCommandToCheckwin == true then
RegisterCommand(Config.CommandCheckwin, function(source, args, rawCommand)
    TriggerEvent('PS_Lottery:CheckWin', source)
	
end)
end

RegisterCommand(Config.AdminMenueCommand, function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "Lottery.AdminMenue") then
    TriggerEvent('PS_Lottery:AdminMenueCheck', source)
    else 
        local msg = translations.NoPermission
        local type = "error"
        NotifyServer(source, msg, type)
    end
end)


RegisterNetEvent('PS_Lottery:lotteryParticipation', function(source)
    if not source then
        print("Error: source is nil")
        return
    end

    local Player
    local firstname
    local lastname
    local playername
    local participation = 1
    local citizenid

        
    local identifierlist = ExtractIdentifiers(source)
    local identifier = identifierlist.license  
    local discord = (identifierlist.discord and identifierlist.discord:gsub("old_pattern", "new_pattern")) or ""
    

    if Config.Framework == "qb-core" then 
        Player = QBCore.Functions.GetPlayer(source)
        if Player then
            firstname = Player.PlayerData.charinfo.firstname
            lastname = Player.PlayerData.charinfo.lastname
            citizenid = Player.PlayerData.citizenid
            playername = firstname .. " " .. lastname
        else
            print("Error: Player not found in QBCore")
            return
        end
    elseif Config.Framework == "ESX" then
        Player = ESX.GetPlayerFromId(source)
        if Player then
            playername = Player.getName()
            identifier =  Player.getIdentifier()
            citizenid = nil
        else
            print("Error: Player not found in ESX")
            return
        end
    else
        print("Error: Unsupported framework")
        return
    end


    local queryCheck
    local params

    if Config.Framework == "qb-core" then
        queryCheck = "SELECT participations FROM lottery_participants WHERE lottery_citizenid = @citizenid"
        params = {['@citizenid'] = citizenid}
    elseif Config.Framework == "ESX" then
        queryCheck = "SELECT participations FROM lottery_participants WHERE identifier = @identifier"
        params = {['@identifier'] = identifier}
    end
    
    MySQL.Async.fetchScalar(queryCheck, params, function(result)
        if result then
 
            local currentParticipations = tonumber(result)
  
            
    
            if currentParticipations >= Config.MaxEntries then
           
                local msg = translations.MaxParticipationReached
                local type = "error"
                NotifyServer(source, msg, type)
                DiscordWebhook(16753920, "PS_Lottery", "Maximum entries reached by: "..identifier.."\n"..discord, "lottery")
            else
              
                local newParticipations = currentParticipations + 1
                local queryUpdate = "UPDATE lottery_participants SET participations = @newParticipations WHERE identifier = @identifier"
                DiscordWebhook(16753920, "PS_Lottery", "The lottery pot has increased by: "..identifier.."\n"..discord, "lottery")
                if Config.Framework == "qb-core" then
                    queryUpdate = "UPDATE lottery_participants SET participations = @newParticipations WHERE lottery_citizenid = @citizenid"
                    DiscordWebhook(16753920, "PS_Lottery", "The lottery pot has increased by: "..identifier.."\n CitizenID: "..citizenid.."\n"..discord, "lottery")
                end
    
                MySQL.Async.execute(queryUpdate, {
                    ['@newParticipations'] = newParticipations,
                    ['@identifier'] = identifier,
                    ['@citizenid'] = citizenid
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        local msg = translations.LotteryJoinedAgain
                        local type = "success"
                        NotifyServer(source, msg, type)
                        checkAndUpdateLotteryPot(participation)
                    else
                        local msg = translations.DatabaseError
                        local type = "error"
                        NotifyServer(source, msg, type)
                    end
                end)
            end
        else
            
            local queryInsert = "INSERT INTO lottery_participants (identifier, lottery_citizenid, playername, participations, discord) VALUES (@identifier, @citizenid, @playername, @participations, @discord)"
            MySQL.Async.execute(queryInsert, {
                ['@identifier'] = identifier,
                ['@citizenid'] = citizenid,
                ['@playername'] = playername,
                ['@participations'] = participation,
                ['@discord'] = discord
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    local msg = translations.LotteryJoined
                    local type = "success"
                    NotifyServer(source, msg, type)
                    checkAndUpdateLotteryPot(participation)
                else
                    local msg = translations.DatabaseError
                    local type = "error"
                    NotifyServer(source, msg, type)
                end
            end)
        end
    end)
end)




RegisterNetEvent('PS_Lottery:lotteryDrawing', function()
    
    local msg = translations.lotteryDrawn 
    local type = "success"
    local source = -1

    NotifyServer(source, msg, type)
  
    local queryParticipants = "SELECT identifier, lottery_citizenid, participations FROM lottery_participants"
    MySQL.Async.fetchAll(queryParticipants, {}, function(participants)
        if participants then
            local totalParticipations = 0
            local participationTable = {}

           
            for _, participant in ipairs(participants) do
                totalParticipations = totalParticipations + participant.participations
                table.insert(participationTable, {
                    identifier = participant.identifier,
                    citizenid = participant.lottery_citizenid,
                    participations = participant.participations
                })
            end
			if totalParticipations == 0 then 
			return
			end
         
            local winningNumber = math.random(1, totalParticipations)
            local currentTotal = 0
            local winnerIdentifier = nil
            local winnerCitizenid = nil

           
            for _, participant in ipairs(participationTable) do
                currentTotal = currentTotal + participant.participations
                if currentTotal >= winningNumber then
                    winnerIdentifier = participant.identifier
                    winnerCitizenid = participant.citizenid
                    break
                end
            end

            if winnerIdentifier then    
                if Config.Framework == "qb-core" then
          
                    TriggerEvent('PS_Lottery:RewardWinner', winnerIdentifier, winnerCitizenid)
                    TriggerEvent('PS_Lottery:ResetParticipants')
                    DiscordWebhook(16753920, "PS_Lottery", "The winner has been drawn: Identifier: "..winnerIdentifier.." CitizenID: "..winnerCitizenid, "lottery")

                elseif Config.Framework == "ESX" then
                    local Player = ESX.GetPlayerFromIdentifier(winnerIdentifier)
                    if Player then
                        TriggerEvent('PS_Lottery:RewardWinner', winnerIdentifier)
                        TriggerEvent('PS_Lottery:ResetParticipants')
                        DiscordWebhook(16753920, "PS_Lottery", "The winner has been drawn: Identifier: "..winnerIdentifier, "lottery")
                    else
                        print("Error: Player not found for identifier " .. winnerIdentifier)
                    end
                else
                    print("Error: Unsupported framework")
                end
            else
                print("Error: No winner identified")
            end
        else
            print("Error: No participants found in the database")
        end
    end)
end)


function checkAndUpdateLotteryPot(participation)
    local increasePot = Config.IncreasePotAmountPerTicket * participation


    local query = "SELECT * FROM lottery_pot LIMIT 1"
    local result = MySQL.Sync.fetchAll(query, {})

    if result and #result > 0 then

        local currentPot = tonumber(result[1].lottery_pot)
        local newPot = currentPot + increasePot
        local updateQuery = "UPDATE lottery_pot SET lottery_pot = @newPot"
        local params = {["@newPot"] = newPot}
        MySQL.Sync.execute(updateQuery, params)
    else

        local insertQuery = "INSERT INTO lottery_pot (lottery_pot) VALUES (@increasePot)"
        local params = {["@increasePot"] = increasePot}
        MySQL.Sync.execute(insertQuery, params)
    end
end


RegisterNetEvent('PS_Lottery:RewardWinner', function(winnerIdentifier, winnerCitizenid)
    local Player


    local query = "SELECT * FROM lottery_pot LIMIT 1"
    local result = MySQL.Sync.fetchAll(query, {})
    
    if result then
        local currentPot = tonumber(result[1].lottery_pot)
        

        local deleteQuery = "DELETE FROM lottery_winner WHERE lottery_winnerid = @winnerIdentifier"
        local deleteParams = { ['@winnerIdentifier'] = winnerIdentifier }

        MySQL.Async.execute(deleteQuery, deleteParams, function(rowsChanged)
            if rowsChanged > 0 then

            else

            end
            

            local insertQuery
            local params = {
                ['@winnerIdentifier'] = winnerIdentifier,
                ['@winningAmount'] = tostring(currentPot)
            }

            if winnerCitizenid then
                insertQuery = "INSERT INTO lottery_winner (lottery_winnerid, lottery_winnercitizenid, lottery_winningamount) VALUES (@winnerIdentifier, @winnerCitizenid, @winningAmount)"
                params['@winnerCitizenid'] = winnerCitizenid
            else
                insertQuery = "INSERT INTO lottery_winner (lottery_winnerid, lottery_winningamount) VALUES (@winnerIdentifier, @winningAmount)"
            end

            MySQL.Async.execute(insertQuery, params, function(rowsChanged)
                if rowsChanged > 0 then

                    if Config.Framework == "qb-core" then
                        Player = QBCore.Functions.GetPlayerByCitizenId(winnerCitizenid)
                        TriggerEvent('PS_Lottery:Resetpot')
                    elseif Config.Framework == "ESX" then
                        Player = ESX.GetPlayerFromIdentifier(winnerIdentifier)
                        TriggerEvent('PS_Lottery:Resetpot')
                    end
                else
                    print("Error: Failed to insert winner into the database")
                end
            end)
        end)
    else
        print(translations.NoMoneyInPot)
    end
end)




RegisterNetEvent('PS_Lottery:CheckWin', function(source)
    local source = source
    local Player
    local identifier
    local citizenid

    if Config.Framework == "qb-core" then
        Player = QBCore.Functions.GetPlayer(source)
        if Player then
            citizenid = Player.PlayerData.citizenid
        else
            print("Error: Player not found in QBCore")
            return
        end
    elseif Config.Framework == "ESX" then
        Player = ESX.GetPlayerFromId(source)
        if Player then
            identifier = Player.getIdentifier()
        else
            print("Error: Player not found in ESX")
            return
        end
    else
        print("Error: Unsupported framework")
        return
    end

    local query
    local params = {}

    if citizenid then
        query = "SELECT * FROM lottery_winner WHERE lottery_winnercitizenid = @citizenid"
        params['@citizenid'] = citizenid
    elseif identifier then
        query = "SELECT * FROM lottery_winner WHERE lottery_winnerid = @identifier"
        params['@identifier'] = identifier
    else
        print("Error: No valid identifier or citizenid found")
        return
    end

    MySQL.Async.fetchAll(query, params, function(result)
        if result and #result > 0 then
            local winningAmount = result[1].lottery_winningamount
            local msg = string.format(translations.YouAreWinner, winningAmount)
            local type = "success"

            NotifyServer(source, msg, type)
			isWinner = true
            TriggerEvent('PS_Lottery:AddMoney', source, winningAmount)
            
            
        else
            local msg = translations.YouAreNotWinner
            local type = "error"

            NotifyServer(source, msg, type)
        end
    end)
end)




RegisterNetEvent('PS_Lottery:AddMoney', function(source, winningAmount)
    local identifierlist = ExtractIdentifiers(source)
    local discord = (identifierlist.discord and identifierlist.discord:gsub("old_pattern", "new_pattern")) or ""
    if isWinner then
        if Config.Framework == "qb-core" then
            local player = QBCore.Functions.GetPlayer(source)
            if player then
                player.Functions.AddMoney(Config.MoneyType, winningAmount, 'Lottwinn')
                TriggerEvent('PS_Lottery:ResetWinner')
                isWinner = false
				DiscordWebhook(16753920, "PS_Lottery", "The winner of the last draw received their prize:"..winningAmount.."\n Winner: "..discord, "lottery")
            end
        elseif Config.Framework == "ESX" then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                local Money = tonumber(winningAmount)
                xPlayer.addAccountMoney(Config.MoneyType, Money)
                TriggerEvent('PS_Lottery:ResetWinner')
                isWinner = false
                DiscordWebhook(16753920, "PS_Lottery", "The winner of the last draw received their prize:"..Money.."\n Winner: "..discord, "lottery")
            end
        end
    end
end)

RegisterNetEvent('PS_Lottery:ResetParticipants', function(source)
    local query = "DELETE FROM lottery_participants"
    
    MySQL.Async.execute(query, {}, function(rowsChanged)
        if rowsChanged > 0 then
            print("All participants have been reseted!")
            DiscordWebhook(16753920, "PS_Lottery", "All participants have been reseted!", "lottery")
        else
            print("No participants to reset.")
        end
    end)
end)

RegisterNetEvent('PS_Lottery:Resetpot', function(source)
    local query = "DELETE FROM lottery_pot"
    
    MySQL.Async.execute(query, {}, function(rowsChanged)
        if rowsChanged > 0 then
            print("The Lotterypot have been reseted!")
            DiscordWebhook(16753920, "PS_Lottery", "Lottery pot has been reseted!", "lottery")
        else
            print("There was nothing in the lotterypot to reset!.")
        end
    end)
end)


RegisterNetEvent('PS_Lottery:ResetWinner', function(source)
    local query = "DELETE FROM lottery_winner"
    
    MySQL.Async.execute(query, {}, function(rowsChanged)
        if rowsChanged > 0 then
            print("The winner has take his winn and it got reseted!")
            DiscordWebhook(16753920, "PS_Lottery", "The winner has take his winn and it got reseted!", "lottery")
        else
            print("There was no winner to reset!.")
        end
    end)
end)

RegisterNetEvent('PS_Lottery:AdminMenueCheck', function(source)

    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM lottery_participants', {}, function(participantCount)
      
        MySQL.Async.fetchScalar('SELECT lottery_pot FROM lottery_pot LIMIT 1', {}, function(potValue)
          
            MySQL.Async.fetchAll('SELECT lottery_winnerid, lottery_winnercitizenid, lottery_winningamount FROM lottery_winner ORDER BY lottery_winnerid DESC LIMIT 1', {}, function(result)
                local lastWinner = result[1]

         
                local lotteryData = {
                    participantCount = participantCount,
                    potValue = potValue,
                    lastWinner = lastWinner
                }


                TriggerClientEvent('PS_Lottery:AdminMenue',source, participantCount, potValue, lastWinner)
            end)
        end)
    end)
end)

RegisterNetEvent('PS_Lottery:UpDateFromAdminMenue', function(potValueNew)

    local identifierlist = ExtractIdentifiers(source)
    local discord = (identifierlist.discord and identifierlist.discord:gsub("old_pattern", "new_pattern")) or ""
    local PotValueNumb = tonumber(potValueNew)

    if not PotValueNumb then
        return
    end

    local increasePot = PotValueNumb


    local query = "SELECT * FROM lottery_pot LIMIT 1"
    local result = MySQL.Sync.fetchAll(query, {})

    if result and #result > 0 then

        local currentPot = tonumber(result[1].lottery_pot)
        local newPot = increasePot
        local updateQuery = "UPDATE lottery_pot SET lottery_pot = @newPot"
        local params = {["@newPot"] = newPot}
        local success, err = MySQL.Sync.execute(updateQuery, params)
        if not success then
           
        end
    else

        local insertQuery = "INSERT INTO lottery_pot (lottery_pot) VALUES (@increasePot)"
        local params = {["@increasePot"] = increasePot}
        local success, err = MySQL.Sync.execute(insertQuery, params)
        if not success then
            
        end
    end
    DiscordWebhook(16753920, "PS_Lottery", "Lottery pot has been updated to:"..potValueNew.. "€ \n By: "..discord, "lottery")
end)




local lotterydraw = lib.cron.new(Config.LotteryDrawAuto, function()
    TriggerEvent('PS_Lottery:lotteryDrawing')
end, { debug = true })

