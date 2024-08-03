local models = Config.TargetPropModels


if Config.UseTarget then
    if Config.TargetSystem == "qb-target" then
	print(json.encode(models))
        exports["qb-target"]:AddTargetModel(
            models,   
            { 
                options = { 
                    { 
                        type = "client", 
                        event = "PS_Lottery:CheckWinClient", 
                        icon = 'fas fa-chair',  
                        label = translations.CheckWin, 
                    } 
                }, 
                distance = 2.5, 
            }
        )

        exports["qb-target"]:AddTargetModel(
            models,   
            { 
                options = { 
                    { 
                        type = "client", 
                        event = "PS_Lottery:CheckStatsClient", 
                        icon = 'fas fa-chair',  
                        label = translations.CheckStatsLabel, 
                    } 
                }, 
                distance = 2.5, 
            }
        )

    elseif Config.TargetSystem == "ox-target" then
        exports.ox_target:addModel(
            models, 
            { 
                { 
                    drawSprite = true,
                    distance = 2.5,
                    event = 'PS_Lottery:CheckWinClient',   
                    icon = 'fas fa-box',              
                    label = translations.CheckWin,     
                    debug = false 
                }
            }
        )

        exports.ox_target:addModel(
            models, 
            { 
                { 
                    drawSprite = true,
                    distance = 2.5,
                    event = 'PS_Lottery:CheckStatsClient',   
                    icon = 'fas fa-box',              
                    label = translations.CheckStatsLabel,     
                    debug = false 
                }
            }
        )
    end
end
