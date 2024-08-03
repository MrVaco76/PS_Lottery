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


if Config.Framework == "qb-core" then 
    QBCore.Functions.CreateUseableItem(Config.LotteryItem, function(source, item)
        local player = QBCore.Functions.GetPlayer(source)
        if player then
            TriggerClientEvent('PS_Lottery:OpenLotteryTicketProgress', source)
        else
            print("Error: QBCore player not found")
        end
    end)
end

if Config.Framework == "ESX" then 
    ESX.RegisterUsableItem(Config.LotteryItem, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            TriggerClientEvent('PS_Lottery:OpenLotteryTicketProgress', source)
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
                        TriggerEvent('PS_Lottery:RemoveItem', source)
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
                    TriggerEvent('PS_Lottery:RemoveItem', source)
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

                        TriggerEvent('PS_Lottery:RewardWinner', winnerIdentifier)
                        TriggerEvent('PS_Lottery:ResetParticipants')
                        DiscordWebhook(16753920, "PS_Lottery", "The winner has been drawn: Identifier: "..winnerIdentifier, "lottery")

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

        local selectQuery = "SELECT * FROM lottery_winner WHERE lottery_winnerid = @winnerIdentifier"
        local selectParams = { ['@winnerIdentifier'] = winnerIdentifier }

        MySQL.Async.fetchAll(selectQuery, selectParams, function(existingWinnerResult)
            if existingWinnerResult and #existingWinnerResult > 0 then
                local existingWinningAmount = tonumber(existingWinnerResult[1].lottery_winningamount)
                local newWinningAmount = existingWinningAmount + currentPot

                local updateQuery = "UPDATE lottery_winner SET lottery_winningamount = @newWinningAmount WHERE lottery_winnerid = @winnerIdentifier"
                local updateParams = { 
                    ['@newWinningAmount'] = tostring(newWinningAmount), 
                    ['@winnerIdentifier'] = winnerIdentifier 
                }

                MySQL.Async.execute(updateQuery, updateParams, function(rowsChanged)
                    if rowsChanged > 0 then
                        if Config.Framework == "qb-core" then
                            Player = QBCore.Functions.GetPlayerByCitizenId(winnerCitizenid)
                            TriggerEvent('PS_Lottery:Resetpot')
                        elseif Config.Framework == "ESX" then
                            Player = ESX.GetPlayerFromIdentifier(winnerIdentifier)
                            TriggerEvent('PS_Lottery:Resetpot')
                        end
                    else
                        print("Error: Failed to update winner in the database")
                    end
                end)
            else
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
            end
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
    local isWinner = false
	local ident
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

    local checkQuery = "SELECT COUNT(*) as count FROM lottery_winner"
    MySQL.Async.fetchAll(checkQuery, {}, function(checkResult)
        if checkResult and checkResult[1].count == 0 then
            local msg = translations.NoEntriesInLottery
            local type = "error"

            NotifyServer(source, msg, type)
            return
        else
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
                    if Config.Framework == "qb-core" then 
						ident = citizenid
                        TriggerEvent("PS_Lottery:ResetWinner", source, ident)
                    elseif Config.Framework == "ESX" then
						ident = identifier
                        TriggerEvent("PS_Lottery:ResetWinner", source, ident)
                    end
                    
                    TriggerEvent('PS_Lottery:AddMoney', source, winningAmount, isWinner)
                    isWinner = false
                else
                    local msg = translations.YouAreNotWinner
                    local type = "error"

                    NotifyServer(source, msg, type)
                end
            end)
        end
    end)
end)


RegisterNetEvent('PS_Lottery:CheckStats', function(source)
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

  
    local potQuery = "SELECT lottery_pot FROM lottery_pot"
    MySQL.Async.fetchAll(potQuery, {}, function(potResult)
        local currentPot
        if potResult and #potResult > 0 then
            currentPot = potResult[1].lottery_pot
        else
            currentPot = "0"
        end

        local participationQuery
        local params = {}

        if citizenid then
            participationQuery = "SELECT participations FROM lottery_participants WHERE lottery_citizenid = @citizenid"
            params['@citizenid'] = citizenid
        elseif identifier then
            participationQuery = "SELECT participations FROM lottery_participants WHERE identifier = @identifier"
            params['@identifier'] = identifier
        else
            print("Error: No valid identifier or citizenid found")
            return
        end

        MySQL.Async.fetchAll(participationQuery, params, function(participationResult)
            local participations
            if participationResult and #participationResult > 0 then
                participations = participationResult[1].participations
            else
                participations = "0"
            end

 
            local msg = string.format(translations.GetStats, currentPot, participations)
            local type = "success"

            NotifyServer(source, msg, type)

        end)
    end)
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


RegisterNetEvent('PS_Lottery:ResetWinner', function(source, ident)
    local query
    local params = {}
    print(ident)
    local identifier
    local citizenid
    if Config.Framework == "qb-core" then 
        citizenid = ident 
        identifier = nil
    elseif Config.Framework == "ESX" then 
        identifier = ident
        citizenid = nil
    end

    if identifier then
        query = "DELETE FROM lottery_winner WHERE lottery_winnerid = @identifier"
        params['@identifier'] = identifier
    elseif citizenid then
        query = "DELETE FROM lottery_winner WHERE lottery_winnercitizenid = @citizenid"
        params['@citizenid'] = citizenid
    else
        print("Neither identifier nor citizenid provided.")
        return
    end

    MySQL.Async.execute(query, params, function(rowsChanged)
        if rowsChanged > 0 then
            print("The winner has taken their win and it got reset!")
            DiscordWebhook(16753920, "PS_Lottery", "The winner has taken their win and it got reset!", "lottery")
        else
            print("There was no winner to reset.")
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
end, { debug = Config.Debug })

