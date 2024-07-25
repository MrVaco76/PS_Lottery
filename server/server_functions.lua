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



function DiscordWebhook(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] ="**" .. message .."**",
              ["footer"] = {
                  ["text"] = footer ,
              },
          }
      }
  
    PerformHttpRequest('PUT HERE YOUR DC WEBHOOK', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end