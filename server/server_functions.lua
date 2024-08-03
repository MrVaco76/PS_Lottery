function NotifyServer(source, msg, type)
    if Config.Framework == "ESX" then
        if type == "primary" then 
            TriggerClientEvent('esx:showNotification', source, msg, type, 5000)    
        end
        if type == "success" then
            TriggerClientEvent('esx:showNotification', source, msg, type, 5000)    
        end
        if type == "error" then
            TriggerClientEvent('esx:showNotification', source, msg, type, 5000) 
        end
    elseif Config.Framework == "qb-core" then
        if type == "primary" then 
            TriggerClientEvent('QBCore:Notify', source, msg, "primary", 5000)     
        end
        if type == "success" then
            TriggerClientEvent('QBCore:Notify', source, msg, "success", 5000)     
        end
        if type == "error" then
            TriggerClientEvent('QBCore:Notify', source, msg, "error", 5000)  
        end
    else
        print("Unknown framework specified in Config.Framework!")
        print("awol")
    end
end

function ExtractIdentifiers(playerId)
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



function DiscordWebhook(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
				["author"] = {
					["icon_url"] = Config.IconURL,
					["name"] = Config.ServerName,
				},
              ["title"] = "**".. name .."**",
              ["description"] ="**" .. message .."**",
              ["footer"] = {
                  ["text"] = os.date('%d/%m/%Y [%X]'),
              },
          }
      }

    PerformHttpRequest('PUT HERE YOUR DC WEBHOOK', function(err, text, headers) end, 'POST', json.encode({username = Config.BotName, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end


  RegisterNetEvent('PS_Lottery:RemoveItem', function(source) 
    local Player
    local xPlayer
    if Config.Framework == "qb-core" then
        Player = QBCore.Functions.GetPlayer(source)
        if Config.Inventory == "Old-QbInventory" then 
			Player.Functions.RemoveItem(Config.LotteryItem, 1)
        elseif Config.Inventory == "New-QbInventory" then 
            exports['qb-inventory']:RemoveItem(source, Config.LotteryItem, 1, false, 'Bakery remove item') 
        elseif Config.Inventory == "OX-Inventory" then 
            exports.ox_inventory:RemoveItem(source, Config.LotteryItem, 1)
        elseif Config.Inventory == "qs-inventory" then 
            exports['qs-inventory']:RemoveItem(source, Config.LotteryItem, 1)
        elseif Config.Inventory == "custom" then 
                 -- Add here your remove item from your inventory
        end
    elseif Config.Framework == "ESX" then 
        xPlayer = ESX.GetPlayerFromId(source)
        if Config.Inventory == "OX-Inventory" then 
            exports.ox_inventory:RemoveItem(source, Config.LotteryItem, 1)
       elseif Config.Inventory == "qs-inventory" then 
            exports['qs-inventory']:RemoveItem(source, Config.LotteryItem, 1)
        elseif Config.Inventory == "custom" then 
            -- Add here your remove item from your inventory)
        end
    end
end)



RegisterNetEvent('PS_Lottery:AddMoney', function(source, winningAmount, isWinner)
    local identifierlist = ExtractIdentifiers(source)
    local discord = (identifierlist.discord and identifierlist.discord:gsub("old_pattern", "new_pattern")) or ""
    if isWinner then
        if Config.Framework == "qb-core" then
            local player = QBCore.Functions.GetPlayer(source)
            if player then
                player.Functions.AddMoney(Config.MoneyType, winningAmount, 'Lottwinn')
                isWinner = false
				DiscordWebhook(16753920, "PS_Lottery", "The winner of the last draw received their prize:"..winningAmount.."\n Winner: "..discord, "lottery")
            end
        elseif Config.Framework == "ESX" then
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then
                local Money = tonumber(winningAmount)
                xPlayer.addAccountMoney(Config.MoneyType, Money)
                isWinner = false
                DiscordWebhook(16753920, "PS_Lottery", "The winner of the last draw received their prize:"..Money.."\n Winner: "..discord, "lottery")
            end
        end
    end
end)
