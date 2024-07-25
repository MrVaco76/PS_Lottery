function Notify(msg, type)
    if Config.Framework == "ESX" then
        if type == "info" then 
            ESX.ShowNotification(msg, type, 5000)   
        end
        if type == "success" then
            ESX.ShowNotification(msg, type, 5000)   
        end
        if type == "error" then
            ESX.ShowNotification(msg, type, 5000)
        end
    elseif Config.Framework == "qb-core" then
        if type == "primary" then 
            QBCore.Functions.Notify(msg, "primary", 5000)
        end
        if type == "success" then
            QBCore.Functions.Notify(msg, "success", 5000)
        end
        if type == "error" then
            QBCore.Functions.Notify(msg, "error", 5000)
        end
    else
        print("Unknown framework specified in Config.Framework!")
    end
end
